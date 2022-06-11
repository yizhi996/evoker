//
//  NZAudioRecorder.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import AVFoundation
import AVFAudio

class NZAudioRecorder: NSObject {
    
    struct Params: Decodable {
        let duration: TimeInterval
        let sampleRate: Float
        let numberOfChannels: Int
        let encodeBitRate: Int
        let format: Foramt
        
        enum Foramt: String, Decodable {
            case aac
            case wav
            
            func toFormatID() -> AudioFormatID {
                switch self {
                case .aac:
                    return kAudioFormatMPEG4AAC
                case .wav:
                    return kAudioFormatLinearPCM
                }
            }
            
            func toExtension() -> String {
                switch self {
                case .aac:
                    return "m4a"
                case .wav:
                    return "wav"
                }
            }
        }
    }
    
    struct RecordData: Encodable {
        let tempFilePath: String
        let duration: TimeInterval
        let fileSize: Int
    }
    
    var recorder: AVAudioRecorder?
    
    var params: Params?
    
    var onStartHandler: NZEmptyBlock?
    
    var onStopHandler: ((RecordData) -> Void)?
    
    var onPauseHandler: NZEmptyBlock?
    
    var onResumeHandler: NZEmptyBlock?
    
    var onInterruptionBeginHandler: NZEmptyBlock?
    
    var onInterruptionEndHandler: NZEmptyBlock?
    
    var onErrorHandler: ((Error) -> Void)?
    
    var currentFile: (String, URL)?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioSessionInterruption(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startRecord(params: Params) {
        if recorder?.isRecording == true {
            return
        }
        self.params = params
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .videoRecording, options: [.mixWithOthers])
            try session.setActive(true)
            
            let settings = [
                AVFormatIDKey: params.format.toFormatID(),
                AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                AVEncoderBitRateKey: params.encodeBitRate,
                AVNumberOfChannelsKey: params.numberOfChannels,
                AVSampleRateKey: params.sampleRate
            ]  as [String : Any]
            let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: params.format.toExtension())
            currentFile = (nzfile, filePath)
            try recorder = AVAudioRecorder(url: filePath, settings: settings)
            recorder!.delegate = self
            let success = recorder!.record(forDuration: params.duration / 1000)
            if success {
                onStartHandler?()
            } else {
                onErrorHandler?(NZError.custom("start record fail"))
            }
        } catch {
            onErrorHandler?(error)
        }
    }
    
    func stop() {
        recorder?.stop()
    }
    
    func pause() {
        guard let recorder = recorder else { return }
        if recorder.isRecording {
            recorder.pause()
            onPauseHandler?()
        }
    }
    
    func resume() {
        guard let recorder = recorder, let params = params else { return }
        if !recorder.isRecording {
            let success = recorder.record(forDuration: params.duration / 1000)
            if success {
                onResumeHandler?()
            } else {
                onErrorHandler?(NZError.custom("resume record fail"))
            }
        }
    }
    
    @objc
    func audioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        guard let userInfo = notification.userInfo as? [String: AVAudioSession.InterruptionType] else { return }
        if userInfo[AVAudioSessionInterruptionTypeKey] == AVAudioSession.InterruptionType.began {
            onInterruptionBeginHandler?()
            pause()
        } else if userInfo[AVAudioSessionInterruptionTypeKey] == AVAudioSession.InterruptionType.ended {
            onInterruptionEndHandler?()
        }
        
        switch type {
        case .began:
            onInterruptionBeginHandler?()
            pause()
        case .ended:
            onInterruptionEndHandler?()
        default:
            break
        }
    }
 
}

extension NZAudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false)
        guard let currentFile = currentFile else {
            onErrorHandler?(NZError.custom("tempFilePath not exist"))
            return
        }
        
        let assets = AVURLAsset(url: currentFile.1)
        let data = RecordData(tempFilePath: currentFile.0,
                              duration: assets.duration.seconds,
                              fileSize: currentFile.1.fileSize)
        onStopHandler?(data)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            onErrorHandler?(error)
        }
    }

}

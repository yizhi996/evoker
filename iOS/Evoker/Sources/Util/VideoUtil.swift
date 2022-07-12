//
//  VideoUtil.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices

struct VideoUtil {
    
    static func cropVideo(url: URL, destURL: URL, compressed: Bool, size: CGSize, completionHandler: @escaping EmptyBlock) {
        let asset = AVAsset(url: url)
        
        let videoTrack = asset.tracks(withMediaType: .video).first!
        
        let (transform, targetSize) = correctVideoTrackTransformAndSize(videoTrack, targetSize: size)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(videoTrack.nominalFrameRate))
        videoComposition.renderSize = targetSize
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        transformer.setTransform(transform, at: .zero)
        
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        let presetName = compressed ? AVAssetExportPresetMediumQuality : AVAssetExportPresetHighestQuality
        let exporter = AVAssetExportSession(asset: asset, presetName: presetName)
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = destURL
        exporter?.outputFileType = .mp4
        exporter?.exportAsynchronously {
            completionHandler()
        }
    }
    
    static func videoPosterImage(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    static func videoTrackDegrees(_ track: AVAssetTrack) -> Int {
        let t = track.preferredTransform
        var degrees = 0
        if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
            // Portrait
            degrees = 90
        } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0{
            // PortraitUpsideDown
            degrees = 270
        } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
            // LandscapeRight
            degrees = 0
        } else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
            // LandscapeLeft
            degrees = 180
        }
        return degrees
    }
    
    static func correctVideoTrackTransformAndSize(_ track: AVAssetTrack, targetSize: CGSize) -> (CGAffineTransform, CGSize) {
        let degrees = videoTrackDegrees(track)
        
        let naturalSize = track.naturalSize
        var transform: CGAffineTransform = .identity
        if degrees == 90 {
            let width = naturalSize.height
            let p = targetSize.height / targetSize.width
            let height = width * p
            let y = (naturalSize.width - height) * 0.5
            transform = transform.translatedBy(x: width, y: -y)
            transform = transform.rotated(by: .pi / 2)
            return (transform, CGSize(width: width, height: height))
        } else if degrees == 180 {
            let width = naturalSize.width
            let p = targetSize.height / targetSize.width
            let height = width * p
            let y = (naturalSize.height - height) * 0.5
            transform = transform.translatedBy(x: width, y: -y)
            transform = transform.rotated(by: .pi)
            return (transform, CGSize(width: width, height: height))
        } else if degrees == 270 {
            let width = naturalSize.height
            let p = targetSize.height / targetSize.width
            let height = width * p
            let y = (naturalSize.width - height) * 0.5
            transform = transform.translatedBy(x: -y, y: width)
            transform = transform.rotated(by: .pi / 2 * 3)
            return (transform, CGSize(width: width, height: height))
        }
        return (transform, targetSize)
    }
    

    enum CompressQuality: String, Decodable {
        case low
        case medium
        case high
    }
    
    typealias CompressVideoCompletionHandler = (FilePath.EKFile, Int, CGSize, EKError?) -> Void
    
    static func compressVideo(url: URL, quality: CompressQuality?, bitrate: Float?, fps: Float?, resolution: CGFloat?, completionHandler handler:  @escaping CompressVideoCompletionHandler) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            handler("", 0, .zero, EKError.bridgeFailed(reason: .contentNotFound))
            return
        }
        
        let asset = AVURLAsset(url: url)
        
        let videoTracks = asset.tracks(withMediaType: .video)
        guard let videoTrack = videoTracks.first else {
            handler("", 0, .zero, EKError.bridgeFailed(reason: .custom("video track not found")))
            return
        }
        
        var targetFPS = videoTrack.nominalFrameRate
        var targetBitrate = videoTrack.estimatedDataRate
        var targetSize = videoTrack.naturalSize
        
        if let quality = quality {
            switch quality {
            case .high:
                targetSize.width *= 0.8
                targetSize.height *= 0.8
            case .medium:
                targetSize.width *= 0.5
                targetSize.height *= 0.5
            case .low:
                targetSize.width *= 0.3
                targetSize.height *= 0.3
            }
        } else {
            if let fps = fps {
                targetFPS = fps
            }
            if let bitrate = bitrate {
                targetBitrate = bitrate
            }
            let resolution = resolution ?? 1
            targetSize.width *= resolution
            targetSize.height *= resolution
        }
        
        let degrees = VideoUtil.videoTrackDegrees(videoTrack)
        var renderSize = videoTrack.naturalSize
        var transform: CGAffineTransform = .identity
        if degrees == 90 {
            transform = transform.translatedBy(x: renderSize.height, y: 0)
            transform = transform.rotated(by: .pi / 2)
            targetSize = CGSize(width: targetSize.height, height: targetSize.width)
            renderSize = CGSize(width: renderSize.height, height: renderSize.width)
        } else if degrees == 180 {
            transform = transform.translatedBy(x: renderSize.width, y: renderSize.height)
            transform = transform.rotated(by: .pi)
        } else if degrees == 270 {
            transform = transform.translatedBy(x: 0, y: renderSize.width)
            transform = transform.rotated(by: .pi / 2 * 3)
            targetSize = CGSize(width: targetSize.height, height: targetSize.width)
            renderSize = CGSize(width: renderSize.height, height: renderSize.width)
        }
  
        let type = asset.url.pathExtension.lowercased()
        guard let outputFileType = VideoUtil.pathExtendsionToAVFileType(type) else {
            let error = EKError.bridgeFailed(reason: .custom("file type not supported, only support mp4, m4v, mov"))
             handler("", 0, .zero, error)
            return
        }

        let (ekfile, destination) = FilePath.generateTmpEKFilePath(ext: type)
        do {
            let reader = try AVAssetReader(asset: asset)
            let writer = try AVAssetWriter(outputURL: destination, fileType: outputFileType)
            
            let videoWriterCompressionSettings: [String : Any] = [
                AVVideoAverageBitRateKey : targetBitrate,
                AVVideoMaxKeyFrameIntervalKey: targetFPS,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
            
            let videoWriterSettings: [String: Any] = [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoCompressionPropertiesKey : videoWriterCompressionSettings,
                AVVideoWidthKey : targetSize.width,
                AVVideoHeightKey : targetSize.height,
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoWriterSettings)
            videoWriterInput.expectsMediaDataInRealTime = true
            if writer.canAdd(videoWriterInput) {
                writer.add(videoWriterInput)
            } else {
                handler("", 0, .zero, EKError.custom("cannot add input"))
                return
            }
            
            let videoReaderOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: nil)
            let videoComposition = AVMutableVideoComposition()
            videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(targetFPS))
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            
            videoComposition.renderSize = renderSize
            
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            transformer.setTransform(transform, at: .zero)
            instruction.layerInstructions = [transformer]
            
            videoComposition.instructions = [instruction]
            videoReaderOutput.videoComposition = videoComposition
            if reader.canAdd(videoReaderOutput) {
                reader.add(videoReaderOutput)
            } else {
                handler("", 0, .zero, EKError.custom("cannot add output"))
                return
            }
            
            var audioWriterInput: AVAssetWriterInput?
            var audioReaderOutput: AVAssetReaderTrackOutput?
            let auduiTracks = asset.tracks(withMediaType: .audio)
            if let audioTrack = auduiTracks.first {
                let audioWriterSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderBitRateKey: audioTrack.estimatedDataRate,
                ]
                audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioWriterSettings)
                audioWriterInput!.expectsMediaDataInRealTime = true
                if writer.canAdd(audioWriterInput!) {
                    writer.add(audioWriterInput!)
                } else {
                    handler("", 0, .zero, EKError.custom("cannot add input"))
                    return
                }

                audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack,
                                                             outputSettings: [AVFormatIDKey: kAudioFormatLinearPCM])
                if reader.canAdd(audioReaderOutput!) {
                    reader.add(audioReaderOutput!)
                } else {
                    handler("", 0, .zero, EKError.custom("cannot add output"))
                    return
                }
            }
            
            if !reader.startReading() {
                handler("", 0, .zero, EKError.custom(reader.error?.localizedDescription ?? "reader error"))
                return
            }
            
            if !writer.startWriting() {
                handler("", 0, .zero, EKError.custom(writer.error?.localizedDescription ?? "writer error"))
                return
            }
            
            writer.startSession(atSourceTime: .zero)
            
            var error: Error?
            let group = DispatchGroup()
            
            func write(input: AVAssetWriterInput, output: AVAssetReaderOutput, queue: DispatchQueue) {
                group.enter()
                input.requestMediaDataWhenReady(on: queue) {
                    while input.isReadyForMoreMediaData {
                        var buffer: CMSampleBuffer?
                        if reader.status == .reading {
                            buffer = output.copyNextSampleBuffer()
                            if let buffer = buffer, !input.append(buffer)  {
                                error = writer.error
                            }
                        } else {
                            error = reader.error
                        }
                        
                        if error != nil || buffer == nil {
                            input.markAsFinished()
                            group.leave()
                            break
                        }
                    }
                }
            }
            
            write(input: videoWriterInput,
                  output: videoReaderOutput,
                  queue: DispatchQueue(label: "com.evokerdev.video-writing-queue"))
            
            if let audioWriterInput = audioWriterInput {
                write(input: audioWriterInput,
                      output: audioReaderOutput!,
                      queue: DispatchQueue(label: "com.evokerdev.audio-writing-queue"))
            }
            
            group.notify(queue: DispatchQueue.main) {
                writer.finishWriting {
                    if let error = error {
                        handler("", 0, .zero, EKError.custom(error.localizedDescription))
                    } else {
                        handler(ekfile, destination.fileSize / 1024, targetSize, nil)
                    }
                }
            }
        } catch {
            handler("", 0, .zero, EKError.custom(error.localizedDescription))
        }
    }
    
    static func pathExtendsionToAVFileType(_ ext: String) -> AVFileType? {
        var outputFileType: AVFileType?
        switch ext {
        case "mp4":
            outputFileType = .mp4
        case "m4v":
            outputFileType = .m4v
        case "mov":
            outputFileType = .mov
        default:
            break
        }
        return outputFileType
    }

}

extension VideoUtil {
    
    static func angleOffsetFromPortraitOrientation(to orientation: AVCaptureVideoOrientation) -> CGFloat {
        var angle: CGFloat = 0.0
        switch orientation {
        case .portrait:
            angle = 0.0
        case .portraitUpsideDown:
            angle = .pi
        case .landscapeRight:
            angle = -(CGFloat.pi / 2)
        case .landscapeLeft:
            angle = .pi / 2
        @unknown default:
            break
        }
        return angle
    }
    
    static func transformFromVideoBufferOrientation(to orientation: AVCaptureVideoOrientation,
                                                    videoOrientation: AVCaptureVideoOrientation,
                                                    videoPosition: AVCaptureDevice.Position,
                                                    autoMirroring: Bool) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        
        let orientationAngleOffset = angleOffsetFromPortraitOrientation(to: orientation)
        let videoOrientationAngleOffset = angleOffsetFromPortraitOrientation(to: videoOrientation)
        let angleOffset = orientationAngleOffset - videoOrientationAngleOffset
        transform = transform.rotated(by: angleOffset)
        
        if videoPosition == .front {
            if autoMirroring {
                transform = transform.scaledBy(x: -1, y: 1)
            } else {
                if UIInterfaceOrientation(rawValue: orientation.rawValue)!.isPortrait {
                    transform = transform.rotated(by: .pi)
                }
            }
        }
        
        return transform
    }
    
    static func transform(with devicePosition: AVCaptureDevice.Position) -> CGAffineTransform {
        let currentInterfaceOrientation = UIApplication.shared.statusBarOrientation
        let originalVideoPrientation: AVCaptureVideoOrientation = devicePosition == .front ? .landscapeLeft : .landscapeRight
        let transform = VideoUtil.transformFromVideoBufferOrientation(to: AVCaptureVideoOrientation(rawValue: currentInterfaceOrientation.rawValue)!, videoOrientation: originalVideoPrientation, videoPosition: devicePosition, autoMirroring: true)
        return transform
    }
    
}

extension VideoUtil {
    
    static func data(with pixelBuffer: CVPixelBuffer, attachments: CFDictionary?, imageType: CFString) -> Data? {
        let ciContext = CIContext()
        let renderedCIImage = CIImage(cvImageBuffer: pixelBuffer)
        guard let renderedCGImage = ciContext.createCGImage(renderedCIImage, from: renderedCIImage.extent) else {
            Logger.error("CVPixelBuffer render to image failed")
            return nil
        }
        
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            Logger.error("CFDataCreateMutable failed")
            return nil
        }
        
        guard let cgImageDestination = CGImageDestinationCreateWithData(data, imageType , 1, nil) else {
            Logger.error("Create CGImageDestination error")
            return nil
        }
        
        CGImageDestinationAddImage(cgImageDestination, renderedCGImage, attachments)
        if CGImageDestinationFinalize(cgImageDestination) {
            return data as Data
        }
        Logger.error("Finalizing CGImageDestination error")
        return nil
    }
}

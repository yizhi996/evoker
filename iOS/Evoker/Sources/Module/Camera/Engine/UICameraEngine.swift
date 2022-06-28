//
//  UICameraEngine.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

class UICameraEngine: NSObject, UINavigationControllerDelegate {
    
    struct PhotoData: Codable {
        let tempFilePath: String
        let tempFile: File
        
        struct File: Codable {
            let path: String
            let size: Int
        }
    }
    
    struct VideoData: Codable {
        let tempFilePath: String
        let duration: TimeInterval
        let size: Int
        let width: CGFloat
        let height: CGFloat
    }
    
    private var currentViewController: UIViewController?
    
    private var compressed = false
    
    private var takePhotoHandler: ((PhotoData) -> Void)?
    
    private var recordVideoHandler: ((VideoData) -> Void)?
    
    var errorHandler: StringBlock?
    
    var cancelHandler: EmptyBlock?
    
    func showTakePhoto(compressed: Bool,
                       to viewController: UIViewController,
                       completionHandler: @escaping (PhotoData) -> Void) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = .camera
        imagePickerViewController.mediaTypes = [kUTTypeImage as String]
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.cameraCaptureMode = .photo
        imagePickerViewController.cameraDevice = .rear
        imagePickerViewController.cameraFlashMode = .auto
        imagePickerViewController.delegate = self
        
        self.compressed = compressed
        takePhotoHandler = completionHandler
        currentViewController = viewController
        viewController.present(imagePickerViewController, animated: true, completion: nil)
    }
    
    func showRecordVideo(device: UIImagePickerController.CameraDevice,
                         maxDuration: TimeInterval,
                         compressed: Bool,
                         to viewController: UIViewController,
                         completionHandler: @escaping (VideoData) -> Void) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = .camera
        imagePickerViewController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.cameraCaptureMode = .video
        imagePickerViewController.cameraDevice = device
        imagePickerViewController.cameraFlashMode = .auto
        imagePickerViewController.delegate = self
        imagePickerViewController.videoMaximumDuration = maxDuration
        imagePickerViewController.videoQuality = .typeHigh
        
        self.compressed = compressed
        recordVideoHandler = completionHandler
        currentViewController = viewController
        viewController.present(imagePickerViewController, animated: true, completion: nil)
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.currentViewController?.dismiss(animated: true, completion: nil)
            self.currentViewController = nil
        }
        errorHandler = nil
        cancelHandler = nil
        takePhotoHandler = nil
        recordVideoHandler = nil
        compressed = false
    }
    
    func processVideo(url: URL, completionHandler: @escaping EmptyBlock) {
        let asset = AVAsset(url: url)
        let duration = asset.duration.seconds
        VideoUtil.compressVideo(url: url,
                                quality: compressed ? .medium : .high,
                                bitrate: nil,
                                fps: nil,
                                resolution: nil) { evfile, fileSize, size, error in
            if error != nil {
                guard let track = asset.tracks(withMediaType: .video).first else {
                    self.errorHandler?("get video track failed")
                    completionHandler()
                    return
                }
                
                let size = track.naturalSize.applying(track.preferredTransform)
                let ext = url.pathExtension.lowercased()
                let (evfile, destination) = FilePath.generateTmpEVFilePath(ext: ext)
                do {
                    try FileManager.default.moveItem(at: url, to: destination)
                    let videoData = VideoData(tempFilePath: evfile,
                                              duration: duration,
                                              size: destination.fileSize,
                                              width: abs(size.width),
                                              height: abs(size.height))
                    self.recordVideoHandler?(videoData)
                } catch {
                    self.errorHandler?("save video to disk fail")
                }
                completionHandler()
            } else {
                try? FileManager.default.removeItem(at: url)
                let videoData = VideoData(tempFilePath: evfile,
                                          duration: duration,
                                          size: fileSize,
                                          width: abs(size.width),
                                          height: abs(size.height))
                self.recordVideoHandler?(videoData)
                completionHandler()
            }
        }
    }
}

extension UICameraEngine: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[.mediaType] as? String else { return }
        
        if mediaType == String(kUTTypeImage) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: compressed ? 0.7 : 1.0) {
                let (evfile, destination) = FilePath.generateTmpEVFilePath(ext: "jpg")
                let success = FileManager.default.createFile(atPath: destination.path,
                                                             contents: imageData,
                                                             attributes: nil)
                if success {
                    let data = PhotoData(tempFilePath: evfile,
                                         tempFile: PhotoData.File(path: evfile, size: imageData.count))
                    takePhotoHandler?(data)
                } else {
                    errorHandler?("save image to disk fail")
                }
                dismiss()
            } else {
                errorHandler?("image not found")
                dismiss()
            }
        } else if let videoURL = info[.mediaURL] as? URL {
            processVideo(url: videoURL) { [unowned self] in
                self.dismiss()
            }
        } else {
            dismiss()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelHandler?()
        errorHandler = nil
        cancelHandler = nil
        takePhotoHandler = nil
        recordVideoHandler = nil
        dismiss()
    }
}

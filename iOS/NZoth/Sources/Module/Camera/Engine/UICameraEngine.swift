//
//  UICameraEngine.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
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
    
    var errorHandler: NZStringBlock?
    
    var cancelHandler: NZEmptyBlock?
    
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
        imagePickerViewController.videoQuality = compressed ? .typeMedium : .typeHigh
        
        self.compressed = compressed
        recordVideoHandler = completionHandler
        currentViewController = viewController
        viewController.present(imagePickerViewController, animated: true, completion: nil)
    }
    
    func dismiss() {
        currentViewController?.dismiss(animated: true, completion: nil)
        currentViewController = nil
        takePhotoHandler = nil
        recordVideoHandler = nil
        cancelHandler = nil
    }
}

extension UICameraEngine: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[.mediaType] as? String else { return }
        if mediaType == String(kUTTypeImage) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: compressed ? 0.7 : 1.0) {
                let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: "jpg")
                let success = FileManager.default.createFile(atPath: filePath.path,
                                                             contents: imageData,
                                                             attributes: nil)
                if success {
                    let data = PhotoData(tempFilePath: nzfile,
                                         tempFile: PhotoData.File(path: nzfile, size: imageData.count))
                    takePhotoHandler?(data)
                } else {
                    errorHandler?("save image to disk fail")
                }
            }
        } else {
            if let videoURL = info[.mediaURL] as? URL {
                let asset = AVAsset(url: videoURL)
                guard let track = asset.tracks(withMediaType: .video).first else {
                    return
                }
                
                let size = track.naturalSize.applying(track.preferredTransform)
               
                let ext = videoURL.pathExtension.lowercased()
                let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: ext)
                do {
                    try FileManager.default.moveItem(at: videoURL, to: filePath)
                    let videoData = VideoData(tempFilePath: nzfile,
                                              duration: asset.duration.seconds,
                                              size: videoURL.fileSize,
                                              width: abs(size.width),
                                              height: abs(size.height))
                    recordVideoHandler?(videoData)
                } catch {
                    errorHandler?("save image to disk fail")
                }
            }
        }
        errorHandler = nil
        cancelHandler = nil
        takePhotoHandler = nil
        recordVideoHandler = nil
        dismiss()
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

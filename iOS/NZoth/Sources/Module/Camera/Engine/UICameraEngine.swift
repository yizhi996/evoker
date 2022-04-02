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

class UICameraEngine: NSObject, UINavigationControllerDelegate {
    
    enum CaptureType: String, Codable {
        case photo
        case video
    }
    
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
        let duration: Float
        let size: Int
        let width: Int
        let height: Int
    }
    
    private var currentViewController: UIViewController?
    
    private var type: CaptureType = .photo
    
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
    
    func showRecordVideo(compressed: Bool,
                         to viewController: UIViewController,
                         completionHandler: @escaping (VideoData) -> Void) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = .camera
        imagePickerViewController.mediaTypes = [kUTTypeVideo as String]
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.cameraCaptureMode = .video
        imagePickerViewController.cameraDevice = .rear
        imagePickerViewController.cameraFlashMode = .auto
        imagePickerViewController.delegate = self
        
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
        if type == .photo {
            guard let image = info[.originalImage] as? UIImage,
                  let imageData = image.jpegData(compressionQuality: compressed ? 0.7 : 1.0) else {
                return
            }
            
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
        } else if type == .video {
            print(info[.mediaURL], info[.mediaMetadata])
        }
        dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelHandler?()
        dismiss()
    }
}

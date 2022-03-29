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
    
    struct Photo: Codable {
        let tempFilePath: String
        let tempFile: File
    }
    
    struct File: Codable {
        let path: String
        let size: Int
    }
    
    struct Video: Codable {
        let tempFilePath: String
        let duration: Float
        let size: Int
        let width: Int
        let height: Int
    }
    
    private var currentViewController: UIViewController?
    private var type: CaptureType = .photo
    
    var takePhotoHandler: ((Photo) -> Void)?
    var recordVideoHandler: ((Video) -> Void)?
    var errorHandler: NZStringBlock?
    var cancelHandler: NZEmptyBlock?
    
    func show(type: CaptureType, to viewController: UIViewController) {
        self.type = type
        if type == .photo {
            showTakePhoto(compressed: false, to: viewController)
        } else if type == .video {
            showRecordVideo(compressed: false, to: viewController)
        }
    }
    
    func showTakePhoto(compressed: Bool, to viewController: UIViewController) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = .camera
        imagePickerViewController.mediaTypes = [kUTTypeImage as String]
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.cameraCaptureMode = .photo
        imagePickerViewController.cameraDevice = .rear
        imagePickerViewController.cameraFlashMode = .auto
        imagePickerViewController.delegate = self
        
        currentViewController = viewController
        viewController.present(imagePickerViewController, animated: true, completion: nil)
    }
    
    func showRecordVideo(compressed: Bool, to viewController: UIViewController) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = .camera
        imagePickerViewController.mediaTypes = [kUTTypeVideo as String]
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.cameraCaptureMode = .video
        imagePickerViewController.cameraDevice = .rear
        imagePickerViewController.cameraFlashMode = .auto
        imagePickerViewController.delegate = self
        
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
                  let imageData = image.jpegData(compressionQuality: 1.0) else {
                return
            }
            
            let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: "jpg")
            let success = FileManager.default.createFile(atPath: filePath.path,
                                                         contents: imageData,
                                                         attributes: nil)
            if success {
                let photo = Photo(tempFilePath: nzfile, tempFile: File(path: nzfile, size: imageData.count))
                takePhotoHandler?(photo)
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

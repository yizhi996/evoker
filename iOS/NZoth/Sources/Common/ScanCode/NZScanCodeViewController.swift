//
//  NZScanCodeViewController.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import ZLPhotoBrowser

class NZScanCodeViewController: UIViewController {
    
    let scanView = NZScanCodeView()
    
    let viewModel: NZScanCodeViewModel
    init(viewModel: NZScanCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        viewModel.cameraEngine.addPreviewTo(view)
        
        scanView.backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        scanView.openAlbumButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        view?.addSubview(scanView)
        scanView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.checkCameraAuth { [unowned self] auth in
            if !auth {
                self.showCameraNotAuthAlert()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.cameraEngine.stopRunning()
    }
    
    func showCameraNotAuthAlert() {
        let appName = Constant.hostName
        let params = NZAlertView.Params(title: "相机权限未开启",
                                        content: "请在 iPhone 的“设置 > \(appName)”选项中，允许\(appName)访问你的摄像头",
                                        showCancel: true,
                                        cancelText: "我知道了",
                                        cancelColor: "#000000",
                                        confirmText: "前往设置",
                                        confirmColor: "#576B95",
                                        editable: false,
                                        placeholderText: nil)
        let alert = NZAlertView(params: params)
        alert.cancelHandler = {
            alert.hide()
        }
        alert.confirmHandler = { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl)
        }
        alert.show(to: view)
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func chooseImage() {
        let ps = ZLPhotoPreviewSheet()
        let config = ZLPhotoConfiguration.default()
        config.allowSelectOriginal = false
        config.allowTakePhotoInLibrary = false
        config.allowSelectVideo = false
        config.maxSelectCount = 1
        ps.selectImageBlock = { [unowned self] images, _, _ in
            guard let image = images.first,
                  let ciImage = CIImage(image: image) else { return }
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
            let features = detector?.features(in: ciImage) ?? []
            if let result = features.first as? CIQRCodeFeature, let value = result.messageString {
                self.viewModel.playSound()
                self.viewModel.scanCompletionHandler?(value, "QR_CODE")
                self.navigationController?.popViewController(animated: true)
            }
        }
        ps.showPhotoLibrary(sender: self)
    }
}

//
//  ScanCodeViewController.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class ScanCodeViewController: UIViewController {
    
    let scanView = ScanCodeView()
    
    let viewModel: ScanCodeViewModel
    init(viewModel: ScanCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
    
    deinit {
        viewModel.cancelHandler?()
        viewModel.cancelHandler = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.checkCameraAuth { [unowned self] auth in
            if !auth {
                self.viewModel.showCameraNotAuthAlert(to: self.view)
            } else {
                self.scanView.scanEffectView.isHidden = false
            }
        }
        
        Engine.shared.currentApp?.uiControl.hideCapsule()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scanView.scanEffectView.isHidden = true
        
        viewModel.cameraEngine.stopRunning()
        
        Engine.shared.currentApp?.uiControl.showCapsule()
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func chooseImage() {
        viewModel.showChooseImage(to: self)
    }
}

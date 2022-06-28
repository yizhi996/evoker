//
//  SettingViewController.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

class SettingViewController: UIViewController {
    
    let viewModel: SettingViewModel
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "设置"
        
        let icon = UIImage.image(light: UIImage(builtIn: "back-arrow-icon")!.withRenderingMode(.alwaysOriginal),
                                 dark: UIImage(builtIn: "back-arrow-icon-dark")!.withRenderingMode(.alwaysOriginal))
        let backBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(onBack))
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.addSubview(viewModel.tableViewInfo.tableView)
        viewModel.tableViewInfo.tableView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appService = Engine.shared.currentApp else { return }
        appService.uiControl.hideCapsule()
        appService.rootViewController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let appService = Engine.shared.currentApp else { return }
        appService.uiControl.showCapsule()
        appService.rootViewController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        viewModel.popViewControllerHandler?()
        viewModel.popViewControllerHandler = nil
    }
    
    @objc
    func onBack() {
        guard let appService = Engine.shared.currentApp else { return }
        appService.rootViewController?.popViewController(animated: true)
    }
}

// InteractivePopGestureRecognizer required
extension SettingViewController: UIGestureRecognizerDelegate {

}

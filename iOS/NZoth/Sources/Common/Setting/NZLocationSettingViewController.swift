//
//  NZLocationSettingViewController.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

class NZLocationSettingViewController: UIViewController {
    
    let viewModel: NZLocationSettingViewModel
    init(viewModel: NZLocationSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "位置信息"
        
        let icon = UIImage.image(light: UIImage(builtIn: "back-arrow-icon")!.withRenderingMode(.alwaysOriginal),
                                 dark: UIImage(builtIn: "back-arrow-icon-dark")!.withRenderingMode(.alwaysOriginal))
        let backBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(onBack))
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        view.addSubview(viewModel.tableViewInfo.tableView)
        viewModel.tableViewInfo.tableView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appService = NZEngine.shared.currentApp else { return }
        appService.uiControl.hideCapsule()
        appService.rootViewController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let appService = NZEngine.shared.currentApp else { return }
        appService.uiControl.showCapsule()
        appService.rootViewController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.popViewControllerHandler?(viewModel.selectedKey)
    }
    
    @objc
    func onBack() {
        guard let appService = NZEngine.shared.currentApp else { return }
        appService.rootViewController?.popViewController(animated: true)
    }
}

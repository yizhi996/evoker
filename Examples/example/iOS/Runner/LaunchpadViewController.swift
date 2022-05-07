//
//  LaunchpadViewController.swift
//  Runner
//
//  Created by yizhi996 on 2022/3/3.
//

import Foundation
import UIKit
import NZoth

class LaunchpadViewController: UIViewController {
    
    struct App {
        let appId: String
        let appName: String
        let appIcon: String
        let envVersion: NZAppEnvVersion
    }
    
    static let apps = [
        App(appId: "com.nzothdev.example",
            appName: "小程序示例",
            appIcon: "",
            envVersion: .develop),
        App(appId: "com.nzothdev.pdd",
            appName: "拼多多",
            appIcon: "",
            envVersion: .develop)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "NZoth"
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        for (i, app) in LaunchpadViewController.apps.enumerated() {
            let button = generateAppButton(title: app.appName)
            button.frame.origin.y = 200.0 + CGFloat(i) * (44.0 + 20.0)
            button.center.x = view.center.x
            button.tag = i
            button.addTarget(self, action: #selector(openApp(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    @objc func openApp(_ button: UIButton) {
        let app = LaunchpadViewController.apps[button.tag]
        var options = NZAppLaunchOptions()
        options.envVersion = app.envVersion
        NZEngine.shared.openApp(appId: app.appId, launchOptions: options)
    }
    
    func generateAppButton(title: String) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 140, height: 44)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .light)
        return button
    }
    
}

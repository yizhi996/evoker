//
//  LaunchpadViewController.swift
//  Test
//

import Foundation
import UIKit
import Evoker

class LaunchpadViewController: UIViewController {
    
    struct App {
        let appId: String
        let appName: String
        let appIcon: String
        let envVersion: AppEnvVersion
    }
    
    static let apps = [
        App(appId: "com.evokerdev.test",
            appName: "Test",
            appIcon: "",
            envVersion: .develop)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Evoker"
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
        var options = AppLaunchOptions()
        options.envVersion = app.envVersion
        Engine.shared.openApp(appId: app.appId, launchOptions: options) { error in
            if let error = error {
                NotifyType.fail("open app failed \(error.localizedDescription)").show()
            }
        }
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

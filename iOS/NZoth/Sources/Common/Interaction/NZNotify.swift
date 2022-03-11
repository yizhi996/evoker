//
//  NZNotify.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZNotifyType {
    
    case success(String)
    case fail(String)
    
    func show() {
        let notify = NZNotifyView(type: self)
        NZNotifyQueue.shared.enqueue(notify)
    }
}

private class NZNotifyQueue {
    
    static let shared = NZNotifyQueue()
    
    lazy var queue: [NZNotifyView] = []
    
    func enqueue(_ notify: NZNotifyView) {
        guard let text = notify.text, !text.isEmpty, let window = UIApplication.shared.keyWindow else { return }
        let maxWidth = Constant.windowWidth - 40
        var height = text.height(with: UIFont.systemFont(ofSize: 16), width: maxWidth)
        height = max(height + 10, 35)
        notify.frame = CGRect(x: 20, y: -height, width: maxWidth, height: height)
        window.addSubview(notify)
        queue.append(notify)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            let maxY = self.queue.last?.frame.maxY ?? 0
            notify.frame.origin.y = Constant.statusBarHeight + Constant.navigationBarHeight + maxY + 10
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                notify.removeFromSuperview()
                self.queue.removeFirst()
            }
        }
    }
}

private class NZNotifyView: UILabel {

    init(type: NZNotifyType) {
        super.init(frame: .zero)
        
        textColor = .white
        numberOfLines = 0
        font = UIFont.systemFont(ofSize: 16.0)
        textAlignment = .center
        
        switch type {
        case .success(let message):
            text = message
            backgroundColor = "#1989fa".hexColor()
        case .fail(let error):
            text = error
            backgroundColor = "#e45353".hexColor()
        }
        
        layer.cornerRadius = 6.0
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

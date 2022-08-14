//
//  Notify.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public enum NotifyType {
    
    case success(String)
    case fail(String)
    
    public func show() {
        let notify = NotifyView(type: self)
        NotifyQueue.shared.enqueue(notify)
    }
}

private class NotifyQueue {
    
    static let shared = NotifyQueue()
    
    lazy var queue: [NotifyView] = []
    
    func enqueue(_ notify: NotifyView) {
        guard let text = notify.text, !text.isEmpty, let window = UIApplication.shared.keyWindow else { return }
        let maxWidth = Constant.windowWidth - 40
        let size = notify.sizeThatFits(CGSize(width: maxWidth, height: .infinity))
        let height = size.height + 10
        notify.frame = CGRect(x: 20, y: -height, width: maxWidth, height: height)
        window.addSubview(notify)
        queue.append(notify)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            notify.frame.origin.y = Constant.statusBarHeight + notify.frame.height + 10
            if self.queue.count > 1 {
                self.queue[0..<self.queue.count - 1].forEach { label in
                    label.frame.origin.y += notify.frame.height + 10
                }
            }
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                notify.removeFromSuperview()
                self.queue.removeFirst()
            }
        }
    }
}

private class NotifyView: UILabel {

    init(type: NotifyType) {
        super.init(frame: .zero)
        
        textColor = .white
        numberOfLines = 0
        font = UIFont.systemFont(ofSize: 16.0)
        textAlignment = .left
        
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

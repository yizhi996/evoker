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
        DispatchQueue.main.async {
            let notify = NotifyView(type: self)
            NotifyQueue.shared.enqueue(notify)
        }
    }
}

private class NotifyQueue {
    
    static let shared = NotifyQueue()
    
    lazy var queue: [NotifyView] = []
    
    func enqueue(_ notify: NotifyView) {
        guard let text = notify.label.text, !text.isEmpty, let window = UIApplication.shared.keyWindow else { return }
        let maxWidth = Constant.windowWidth - 40 - 20
        let size = notify.label.sizeThatFits(CGSize(width: maxWidth, height: .infinity))
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

private class NotifyView: UIView {
    
    let label = UILabel()
    
    init(type: NotifyType) {
        super.init(frame: .zero)
        
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textAlignment = .left
        addSubview(label)
        
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        label.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)
        
        switch type {
        case .success(let message):
            label.text = message
            backgroundColor = "#1989fa".hexColor()
        case .fail(let error):
            label.text = error
            backgroundColor = "#e45353".hexColor()
        }
        
        layer.cornerRadius = 6.0
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

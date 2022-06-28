//
//  UIView+Animation.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension UIView {
    
    func rotation(duration: TimeInterval = 1.0) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        layer.add(rotationAnimation, forKey: "rotationAnimationKey")
    }
    
    func stopRotation() {
        layer.removeAnimation(forKey: "rotationAnimationKey")
    }
    
    func translationY(duration: TimeInterval = 1.0, from: CGFloat, to: CGFloat) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        rotationAnimation.fromValue = from
        rotationAnimation.toValue = to
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        layer.add(rotationAnimation, forKey: "translationYAnimationKey")
    }
    
    func stopTranslationY() {
        layer.removeAnimation(forKey: "translationYAnimationKey")
    }
    
    func fadeIn(duration: TimeInterval = 0.3, ease: UIView.AnimationOptions = .curveEaseInOut, completionHandler handler: EmptyBlock? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: ease) {
            self.alpha = 1.0
        } completion: { finished in
            handler?()
        }
    }
    
    func fadeOut(duration: TimeInterval = 0.3, ease: UIView.AnimationOptions = .curveEaseInOut, completionHandler handler: EmptyBlock? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: ease) {
            self.alpha = 0.0
        } completion: { finished in
            handler?()
        }
    }
    
    func popup(duration: TimeInterval = 0.5, completionHandler handler: EmptyBlock? = nil) {
        layer.transform = CATransform3DMakeTranslation(0.0, Constant.windowHeight, 0.0)
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 1, 0.5, 1)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: duration) {
            self.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
        } completion: { finished in
            handler?()
        }
        CATransaction.commit()
    }
    
    func popdown(duration: TimeInterval = 0.3, completionHandler handler: EmptyBlock? = nil) {
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.11, 0, 0.5, 0)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: duration) {
            self.layer.transform = CATransform3DMakeTranslation(0.0, Constant.windowHeight, 0.0)
        } completion: { finished in
            handler?()
        }
        CATransaction.commit()
    }
}

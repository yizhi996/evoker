//
//  TestUtils.swift
//  Test
//

import Foundation
import UIKit
import Evoker
import JavaScriptCore

class TestModule: Module {
    
    static var name: String {
        return "com.evokerdev.test.module"
    }
    
    static var apis: [String : API] {
        return [:]
    }
    
    required init(appService: AppService) {
        let utils = TestUtils()
        utils.appService = appService
        appService.context.binding(utils, name: "__TestUtils")
    }
    
}

@objc protocol TestUtilsExport: JSExport {
    
    init()
    
    func containText(_ text: String) -> Bool
    
    func containImage(_ name: String) -> Bool
    
    func findFirstResponderInput() -> UIViewObject?
    
    func findUIButtonWithTitle(_ title: String) -> UIButtonObject?
    
    func findUIViewWithClass(_ class: String) -> UIViewObject?
    
    func findUILabelWithText(_ text: String) -> UILabelObject?
    
    func clickTableViewCellWithTitle(_ title: String)
    
}

@objc class TestUtils: NSObject, TestUtilsExport {
    
    weak var appService: AppService?
    
    override required init() {
        super.init()
    }
    
    @discardableResult
    func performMainThread(execute work: @escaping (inout Any?, () -> Void) -> Void) -> Any? {
        let group = DispatchGroup()
        group.enter()
        var result: Any? = nil
        DispatchQueue.main.async {
            work(&result, group.leave)
        }
        group.wait()
        return result
    }
    
    func findView(where predicate: (UIView) throws -> Bool) rethrows -> UIView? {
        guard let appService = appService else { return nil }
        return try appService.rootViewController?.view.dfsFindSubview(reversed: true, where: predicate)
    }
    
    func containText(_ text: String) -> Bool {
        return performMainThread { result, leave in
            result = self.findView { view in
                if let label = view as? UILabel, label.text == text {
                    return true
                } else if let textView = view as? UITextView, textView.text == text {
                    return true
                } else if let button = view as? UIButton, button.title(for: .normal) == text {
                    return true
                } else {
                    return false
                }
            }
            leave()
        } != nil
    }
    
    func containImage(_ name: String) -> Bool {
        return performMainThread { result, leave in
            let target = UIImage(builtIn: name)
            result = self.findView { view in
                if let imageView = view as? UIImageView, !imageView.isHidden, imageView.image == target {
                    return true
                } else {
                    return false
                }
            }
            leave()
        } != nil
    }
    
    func findUIButtonWithTitle(_ title: String) -> UIButtonObject? {
        return performMainThread { result, leave in
            let button = self.findView { view in
                if let button = view as? UIButton, button.title(for: .normal) == title {
                    return true
                } else {
                    return false
                }
            }
            result = button?.toObject()
            leave()
        } as? UIButtonObject
    }
    
    func findFirstResponderInput() -> UIViewObject? {
        return performMainThread { result, leave in
            let input = self.findView { view in
                if let input = view as? UITextView, input.isFirstResponder {
                    return true
                } else if let input = view as? UITextField, input.isFirstResponder {
                    return true
                } else {
                    return false
                }
            }
            result = input?.toObject()
            leave()
        } as? UIViewObject
    }
    
    func findUIViewWithClass(_ className: String) -> UIViewObject? {
        guard let cls = NSClassFromString(className) else { return nil }
        return performMainThread { result, leave in
            let view = self.findView { view in
                if view.isKind(of: cls) {
                    return true
                } else {
                    return false
                }
            }
            result = view?.toObject()
            leave()
        } as? UIViewObject
    }
    
    func findUILabelWithText(_ text: String) -> UILabelObject? {
        return performMainThread { result, leave in
            let label = self.findView { view in
                if let label = view as? UILabel, label.text == text {
                    return true
                } else {
                    return false
                }
            }
            result = label?.toObject()
            leave()
        } as? UILabelObject
    }
    
    func clickTableViewCellWithTitle(_ title: String) {
        performMainThread { result, leave in
            let label = self.findView { view in
                if let label = view as? UILabel, label.text == title {
                    return true
                } else {
                    return false
                }
            } as? UILabel
            if let cell = label?.superview?.superview as? UITableViewCell {
                let tableView = cell.superview as! UITableView
                let indexPath = tableView.indexPath(for: cell)!
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
            }
            leave()
        }
    }
}

@objc protocol UIViewExport: JSExport {
    
    var rect: [String: CGFloat] { get }
    
    var backgroundColor: String { get set }
    
    init()
    
}

@objc class UIViewObject: NSObject, UIViewExport {
    
    var view: UIView!
    
    var rect: [String: CGFloat] {
        return ["x": view.frame.minX,
                "y": view.frame.minY,
                "width": view.frame.width,
                "height": view.frame.height]
    }
    
    var backgroundColor: String {
        get {
            return view.backgroundColor?.hexString() ?? ""
        } set {
            DispatchQueue.main.async {
                self.view.backgroundColor = newValue.hexColor()
            }
        }
    }
    
    required override init() {
        super.init()
    }
    
    init(view: UIView) {
        self.view = view
        super.init()
    }
}

extension UIView {
    
    @objc
    func toObject() -> JSExport {
        return UIViewObject(view: self)
    }
}

@objc protocol UILabelExport: JSExport, UIViewExport {
    
    var text: String { get set }
    
    var textColor: String { get set }
    
    var font: [String: Any] { get }
    
    init()
    
}

@objc class UILabelObject: UIViewObject, UILabelExport {
    
    var label: UILabel {
        return view as! UILabel
    }
    
    var text: String {
        get {
            return label.text ?? ""
        } set {
            DispatchQueue.main.async {
                self.label.text = newValue
            }
        }
    }
    
    var textColor: String {
        get {
            return label.textColor.hexString()
        } set {
            DispatchQueue.main.async {
                self.label.textColor = newValue.hexColor()
            }
        }
    }
        
    var font: [String: Any] {
        get {
            let label = (view as! UILabel)
            return ["size": label.font.pointSize,
                    "weight": label.font.fontDescriptor.object(forKey: .face) as! String]
        }
    }
    
}

extension UILabel {
    
    override func toObject() -> JSExport {
        return UILabelObject(view: self)
    }
}

@objc protocol UIButtonExport: JSExport, UIViewExport {
    
    var title: String { get }
    
    var titleColor: String { get }
    
    func click()
    
    init()
    
}

@objc class UIButtonObject: UIViewObject, UIButtonExport {
    
    
    var button: UIButton {
        return view as! UIButton
    }
    
    var title: String {
        get {
            return button.title(for: .normal) ?? ""
        }
    }
    
    var titleColor: String {
        get {
            return button.titleColor(for: .normal)?.hexString() ?? ""
        }
    }
    
    func click() {
        DispatchQueue.main.async {
            self.button.sendActions(for: .touchUpInside)
        }
    }
}

extension UIButton {
    
    override func toObject() -> JSExport {
        return  UIButtonObject(view: self)
    }
}

@objc protocol UITextViewExport: JSExport, UIViewExport {
    
    var text: String { get set }
    
    init()
    
}

@objc class UITextViewObject: UIViewObject, UITextViewExport {
    
    var textView: UITextView {
        return view as! UITextView
    }
    
    var text: String {
        get {
            return textView.text
        } set {
            DispatchQueue.main.async {
                self.textView.text = newValue
                self.textView.delegate?.textViewDidChange?(self.textView)
            }
        }
    }
    
}

extension UITextView {
    
    override func toObject() -> JSExport {
        return  UITextViewObject(view: self)
    }
}

extension UIColor {
    
    func hexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red = (red * 255).rounded()
        green = (green * 255).rounded()
        blue = (blue * 255).rounded()
        alpha = (alpha * 255).rounded()
        
        let hex = (UInt(red) << 16) | (UInt(green) << 8) | UInt(blue)
        
        return String(format: "#%06x", hex)
    }
}

extension String {
    
    func hexColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hexString: self, alpha: alpha) ?? .black
    }
}

private extension Int {
    func duplicate4bits() -> Int {
        return (self << 4) + self
    }
}

private extension UIColor {
    
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        
        guard let hexVal = Int(hex, radix: 16) else {
            return nil
        }
        
        switch hex.count {
        case 3:
            self.init(hex3: hexVal, alpha: alpha)
        case 6:
            self.init(hex6: hexVal, alpha: alpha)
        default:
            return nil
        }
    }
}

private extension UIColor {
    
    convenience init?(hex3: Int, alpha: CGFloat) {
        self.init(red:   CGFloat( ((hex3 & 0xF00) >> 8).duplicate4bits() ) / 255.0,
                  green: CGFloat( ((hex3 & 0x0F0) >> 4).duplicate4bits() ) / 255.0,
                  blue:  CGFloat( ((hex3 & 0x00F) >> 0).duplicate4bits() ) / 255.0,
                  alpha: alpha)
    }
    
    convenience init?(hex6: Int, alpha: CGFloat) {
        self.init(red:   CGFloat( (hex6 & 0xFF0000) >> 16 ) / 255.0,
                  green: CGFloat( (hex6 & 0x00FF00) >> 8 ) / 255.0,
                  blue:  CGFloat( (hex6 & 0x0000FF) >> 0 ) / 255.0,
                  alpha: alpha)
    }

}

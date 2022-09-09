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
    
    func findText(_ text: String) -> Bool
    
    func findImage(_ name: String) -> Bool
    
    func findFirstResponderInput() -> String?
    
    func findUIButtonWithTitle(_ title: String) -> [String: Any]
    
    func findUIViewWithClass(_ class: String) -> [String: Any]
    
    func findUILabelWithText(_ text: String) -> [String: Any]
    
    func setInput(_ id: String, _ text: String)
    
    func clickButtonWithId(_ id: String)
    
    func clickButtonWithTitle(_ title: String)
    
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
    
    func findText(_ text: String) -> Bool {
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
    
    func findImage(_ name: String) -> Bool {
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
    
    func findUIButtonWithTitle(_ title: String) -> [String: Any] {
        return performMainThread { result, leave in
            let button = self.findView { view in
                if let button = view as? UIButton, button.title(for: .normal) == title {
                    return true
                } else {
                    return false
                }
            }
            if let button = button {
                result = button.toObject()
            } else {
                result = [:]
            }
            leave()
        } as! [String : Any]
    }
    
    func findFirstResponderInput() -> String? {
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
            if let input = input {
                if input.id == nil {
                    input.id = String.random(length: 5)
                }
                result = input.id!
            } else {
                result = nil
            }
            leave()
        } as! String?
    }
    
    func findUIViewWithClass(_ className: String) -> [String: Any] {
        guard let cls = NSClassFromString(className) else { return [:] }
        return performMainThread { result, leave in
            let view = self.findView { view in
                if view.isKind(of: cls) {
                    return true
                } else {
                    return false
                }
            }
            if let view = view {
                result = view.toObject()
            } else {
                result = [:]
            }
            leave()
        } as! [String : Any]
    }
    
    func findUILabelWithText(_ text: String) -> [String: Any] {
        return performMainThread { result, leave in
            let label = self.findView { view in
                if let label = view as? UILabel, label.text == text {
                    return true
                } else {
                    return false
                }
            }
            if let label = label {
                result = label.toObject()
            } else {
                result = [:]
            }
            leave()
        } as! [String : Any]
    }
    
    func setInput(_ id: String, _ text: String) {
        performMainThread { result, leave in
            let input = self.findView { view in
                if view.id == id {
                    return true
                } else {
                    return false
                }
            }
            if let input = input as? UITextView {
                input.text = text
                input.delegate?.textViewDidChange?(input)
            } else if let input = input as? UITextField {
                input.text = text
            }
            leave()
        }
    }
    
    func clickButtonWithId(_ id: String) {
        performMainThread { result, leave in
            let button = self.findView { view in
                if let button = view as? UIButton, button.id == id {
                    return true
                } else {
                    return false
                }
            } as? UIButton
            if let button = button {
                button.sendActions(for: .touchUpInside)
            }
            leave()
        }
    }
    
    func clickButtonWithTitle(_ title: String) {
        performMainThread { result, leave in
            let button = self.findView { view in
                if let button = view as? UIButton, button.title(for: .normal) == title {
                    return true
                } else {
                    return false
                }
            } as? UIButton
            if let button = button {
                button.sendActions(for: .touchUpInside)
            }
            leave()
        }
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

extension UIView {
    
    @objc
    func toObject() -> [String: Any] {
        if id == nil {
            id = String.random(length: 6)
        }
        return ["id": id!,
                "rect": ["x": frame.minX,
                         "y": frame.minY,
                         "width": frame.width,
                         "height": frame.height],
                "backgroundColor": backgroundColor?.hexString() ?? ""]
    }
}

extension UILabel {
    
    override func toObject() -> [String: Any] {
        var object = super.toObject()
        
        object["text"] = text ?? ""
        object["textColor"] = textColor.hexString()
        object["font"] = ["size": font.pointSize,
                          "weight": font.fontDescriptor.object(forKey: .face) as! String]
        return object
    }
}

extension UIButton {
    
    override func toObject() -> [String: Any] {
        var object = super.toObject()
        
        object["title"] = title(for: .normal) ?? ""
        object["titleColor"] = titleColor(for: .normal)?.hexString() ?? ""
        return object
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


extension UIView {
    
    private static var idKey = "TEST_ID"
    
    var id: String? {
        get {
            objc_getAssociatedObject(self, &Self.idKey) as! String?
        } set {
            objc_setAssociatedObject(self, &Self.idKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension String {
    
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

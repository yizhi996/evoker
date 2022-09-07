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
    
    func findButton(_ title: String) -> [String: Any]
    
    func findFirstResponderInput() -> String?
    
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
    
    func findText(_ text: String) -> Bool {
        guard let appService = appService else { return false }
        return performMainThread { result, leave in
            result = appService.rootViewController?.view.dfsFindSubview{ view in
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
        guard let appService = appService else { return false }
        return performMainThread { result, leave in
            let target = UIImage(builtIn: name)
            result = appService.rootViewController?.view.dfsFindSubview{ view in
                if let imageView = view as? UIImageView, imageView.image == target {
                    return true
                } else {
                    return false
                }
            }
            leave()
        } != nil
    }
    
    func findButton(_ title: String) -> [String: Any] {
        guard let appService = appService else { return [:] }
        return performMainThread { result, leave in
            let button = appService.rootViewController?.view.dfsFindSubview{ view in
                if let button = view as? UIButton, button.title(for: .normal) == title {
                    return true
                } else {
                    return false
                }
            } as? UIButton
            if let button = button {
                if button.id == nil {
                    button.id = String.random(length: 5)
                }
                result = ["id": button.id,
                          "title": button.title(for: .normal) ?? "",
                          "titleColor": button.titleColor(for: .normal)?.hexString() ?? ""]
            } else {
                result = [:]
            }
            leave()
        } as! [String : Any]
    }
    
    func findFirstResponderInput() -> String? {
        guard let appService = appService else { return nil }
        return performMainThread { result, leave in
            let input = appService.rootViewController?.view.dfsFindSubview{ view in
                if let input = view as? UITextView, input.isFirstResponder {
                    return true
                } else if let input = view as? UITextField, input.isFirstResponder {
                    return true
                } else {
                    return false
                }
            } as? UIView
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
    
    func setInput(_ id: String, _ text: String) {
        guard let appService = appService else { return }
        performMainThread { result, leave in
            let input = appService.rootViewController?.view.dfsFindSubview{ view in
                if view.id == id {
                    return true
                } else {
                    return false
                }
            } as? UIView
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
        guard let appService = appService else { return }
        performMainThread { result, leave in
            let button = appService.rootViewController?.view.dfsFindSubview{ view in
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
        guard let appService = appService else { return }
        performMainThread { result, leave in
            let button = appService.rootViewController?.view.dfsFindSubview{ view in
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
        guard let appService = appService else { return }
        performMainThread { result, leave in
            let label = appService.rootViewController?.view.dfsFindSubview{ view in
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

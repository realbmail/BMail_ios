//
//  Utils.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/26.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    var stringVal : String {
        Formatter.date.calendar = Calendar(identifier: .iso8601)
        Formatter.date.timeZone = .current
        Formatter.date.dateFormat = "yyyy-MM-dd"
        return Formatter.date.string(from: self)
    }
}

func toDate(str:String, format:String) -> Date{
        Formatter.date.dateFormat = format
        return Formatter.date.date(from:str)!
}

extension Double{
        public func ToCoin() -> String{
                let val = self/Constants.CoinDecimal
                return String.init(format: "%.2f", val)
        }
        
        public func ToString() -> String{
                return String.init(format: "%.2f", self)
        }
}

func createLabelWithDynamicHeight(_ width: CGFloat, _ fontSize: CGFloat) -> UILabel {
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    
    label.textColor=UIColor.black
    label.lineBreakMode = .byWordWrapping
        //TODO::
        label.font = UIFont.systemFont(ofSize: 12)//(name: "NunitoSans-Regular", size: fontSize)!// Font.regular.size(fontSize)
    label.numberOfLines = 0
    
    return label
}

func getLabelHeight(_ text: Any, width: CGFloat, fontSize: CGFloat) -> CGFloat {
    let label = createLabelWithDynamicHeight(width, fontSize)
    if text is NSMutableAttributedString {
        label.attributedText = text as! NSMutableAttributedString
    } else {
        label.text = text as? String
    }
    
    label.sizeToFit()
    return label.frame.height
}

func generateQRCode(from message: String) -> UIImage? {
        
        guard let data = message.data(using: .utf8) else{
                return nil
        }
        
        guard let qr = CIFilter(name: "CIQRCodeGenerator",
                                parameters: ["inputMessage":
                                        data, "inputCorrectionLevel":"M"]) else{
                return nil
        }
        
        guard let qrImage = qr.outputImage?.transformed(by: CGAffineTransform(scaleX: 5, y: 5)) else{
                return nil
        }
        let context = CIContext()
        let cgImage = context.createCGImage(qrImage, from: qrImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        return uiImage
}

extension UIStoryboard {
        static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
        static func leftViewController() -> MenuViewController? {
                return mainStoryboard().instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        }
        static func centerViewController(name:String) -> CenterViewController? {
                return mainStoryboard().instantiateViewController(withIdentifier: name) as? CenterViewController
        }
        
        static func viewController(name:String) -> UIViewController {
                return mainStoryboard().instantiateViewController(withIdentifier: name)
        }
}

extension UIColor {

convenience init(RRGGBB: UInt, alpha: CGFloat) {
    self.init(
        red: CGFloat((RRGGBB & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((RRGGBB & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(RRGGBB & 0x0000FF) / 255.0,
        alpha: alpha
    )
}

convenience init(RRGGBB: UInt) {
    self.init(
        red: CGFloat((RRGGBB & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((RRGGBB & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(RRGGBB & 0x0000FF) / 255.0,
        alpha: 1.0
    )
}

convenience init(r: CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) {
    self.init(
        red: r / 255.0,
        green: g / 255.0,
        blue: b / 255.0,
        alpha: a
    )
}

}

extension UIColor {

    convenience init(hexColorCode: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hexColorCode.hasPrefix("#") {
            let index   = hexColorCode.index(hexColorCode.startIndex, offsetBy: 1)
            let hex     = String(hexColorCode[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            
            if scanner.scanHexInt64(&hexValue) {
                if hex.count == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.count == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    NSLog("invalid hex code string, length should be 7 or 9")
                }
            } else {
                NSLog("scan hex error")
            }
        } else {
            NSLog("invalid hex code string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

// Other Methods
extension UIColor {
    /**
     Create non-autoreleased color with in the given hex string and alpha
     
     :param:   hexString
     :param:   alpha
     :returns: color with the given hex string and alpha
     
     
     Example:
     
     // With hash
     let color: UIColor = UIColor(hexString: "#ff8942")
     
     // Without hash, with alpha
     let secondColor: UIColor = UIColor(hexString: "ff8942", alpha: 0.5)
     
     // Short handling
     let shortColorWithHex: UIColor = UIColor(hexString: "fff")
     */
    
    convenience init(hexString: String, alpha: Float) {
        var hex = hexString
        
        // Check for hash and remove the hash
        if hex.hasPrefix("#") {
            let hexL = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[hexL...])
        }
        
        if hex.count == 0 {
            hex = "000000"
        }
        
        let hexLength = hex.count
        // Check for string length
        assert(hexLength == 6 || hexLength == 3)
        
        // Deal with 3 character Hex strings
        if hexLength == 3 {
            let redR = hex.index(hex.startIndex, offsetBy: 1)
            let redHex = String(hex[..<redR])
            let greenL = hex.index(hex.startIndex, offsetBy: 1)
            let greenR = hex.index(hex.startIndex, offsetBy: 2)
            let greenHex = String(hex[greenL..<greenR])
            let blueL = hex.index(hex.startIndex, offsetBy: 2)
            let blueHex = String(hex[blueL...])
            hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
        }
        let redR = hex.index(hex.startIndex, offsetBy: 2)
        let redHex = String(hex[..<redR])
        let greenL = hex.index(hex.startIndex, offsetBy: 2)
        let greenR = hex.index(hex.startIndex, offsetBy: 4)
        let greenHex = String(hex[greenL..<greenR])
        
        let blueL = hex.index(hex.startIndex, offsetBy: 4)
        let blueR = hex.index(hex.startIndex, offsetBy: 6)
        let blueHex = String(hex[blueL..<blueR])
        
        var redInt:   CUnsignedInt = 0
        var greenInt: CUnsignedInt = 0
        var blueInt:  CUnsignedInt = 0
        
        Scanner(string: redHex).scanHexInt32(&redInt)
        Scanner(string: greenHex).scanHexInt32(&greenInt)
        Scanner(string: blueHex).scanHexInt32(&blueInt)
        
        self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
    }
    
    /**
     Create non-autoreleased color with in the given hex value and alpha
     
     :param:   hex
     :param:   alpha
     :returns: color with the given hex value and alpha
     
     Example:
     let secondColor: UIColor = UIColor(hex: 0xff8942, alpha: 0.5)
     
     */
    convenience init(hex: Int, alpha: Float) {
        let hexString = NSString(format: "%2X", hex)
        self.init(hexString: hexString as String, alpha: alpha)
    }
}

extension UITextField {
    
        func addInputAccessoryView(title: String, flag:Int, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        barButton.tag = flag
        self.inputAccessoryView = toolBar//5
    }

    
    
    func setLeftPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}




extension RichEditorView {
    /// Reads a file from the application's bundle, and returns its contents as a string
    /// Returns nil if there was some error
    func readFile(name: String, type: String) -> String? {
        
        if let filePath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let file = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
                return file
            } catch let error {
                print("Error loading \(name).\(type): \(error)")
            }
        }
        return nil
    }
    
    func cleanStringForJS(_ string: String) -> String {
        let substitutions = [
            "\"": "\\\"",
            "'": "\\'",
            "\n": "\\\n",
            ]
        
        var output = string
        for (key, value) in substitutions {
            output = (output as NSString).replacingOccurrences(of: key, with: value)
        }
        
        return output
    }
    
    /// Creates a JS string that can be run in the WebView to apply the passed in CSS to it
    func addCSSString(style: String) -> String {
        let css = self.cleanStringForJS(style)
        let js = "var css = document.createElement('style'); css.type = 'text/css'; css.innerHTML = '\(css)'; document.body.appendChild(css);"
        return js
    }
    
    func replace(font:String, css:String){
        if var customCSS = self.readFile(name: css, type: "css") {
            /// Replace the font with the actual location of the font inside our bundle
            if let fontLocation = Bundle.main.path(forResource: font, ofType: "ttf") {
                customCSS = customCSS.replacingOccurrences(of: font, with: fontLocation)
            }
            let js = self.addCSSString(style: customCSS)
            self.runJS(js)
        }
    }
}

func IsValidUsername(_ testStr:String) -> Bool {
    let emailRegEx = "(?=^([a-z0-9]([._-]{0,2}[a-z0-9])+)$)(?:^.{3,64}$)$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}
func ValidateEmail(_ testStr:String) -> Bool {
//    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailRegEx = "^[A-Z0-9a-z._+-]+@[A-Za-z0-9-_]+(\\.[A-Za-z]{2,64})*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}
func GetImageByFileType(_ type: String) -> UIImage {
    switch type {
    case "application/pdf":
        return #imageLiteral(resourceName: "attachment_pdf")
    case _ where type.contains("word"):
        return #imageLiteral(resourceName: "attachment_word")
    case "image/png", "image/jpeg":
        return #imageLiteral(resourceName: "attachment_image")
    case _ where type.contains("powerpoint") ||
        type.contains("presentation"):
        return #imageLiteral(resourceName: "attachment_ppt")
    case _ where type.contains("excel") ||
        type.contains("spreadsheet"):
        return #imageLiteral(resourceName: "attachment_excel")
    case _ where type.contains("audio"):
        return #imageLiteral(resourceName: "attachment_audio")
    case _ where type.contains("video"):
        return #imageLiteral(resourceName: "attachment_video")
    case _ where type.contains("zip"):
        return #imageLiteral(resourceName: "attachment_zip")
    default:
        return #imageLiteral(resourceName: "attachment_generic")
    }
}

func SetProfilePictureImage(imageView: UIImageView, contact: CDContact) {
//    let color = UIColor.init().colorByName(name: contact.displayName)
//    imageView.setImageWith(contact.displayName, color: color, circular: true, fontName: "NunitoSans-Regular")
//    imageView.layer.borderWidth = 0.0
    
//    let (username, domain) = GetUsernameAndDomain(email: contact.email)
//    imageView.sd_setImage(with: URL(string: "\(Env.apiURL)/user/avatar/\(domain)/\(username)"), placeholderImage: imageView.image, options: [SDWebImageOptions.continueInBackground, SDWebImageOptions.lowPriority]) { (image, error, cacheType, url) in
//        if error == nil {
//            imageView.contentMode = .scaleAspectFill
//            imageView.layer.masksToBounds = false
//            imageView.layer.cornerRadius = imageView.frame.size.width / 2
//            imageView.clipsToBounds = true
//        }
//    }
    
}


func IsSystemDarlkModeEnabled(controller: UIViewController) -> Bool {
    if #available(iOS 12.0, *) {
        switch controller.traitCollection.userInterfaceStyle {
        case .dark:
            return true
        default:
            return false
        }
    } else {
        return false
    }
}

extension String {
        var locStr:String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localize(arguments: CVarArg...) -> String {
        return String(format: self.locStr, arguments: arguments)
    }
    
    func hideAtChars() -> String {
        return String(self.enumerated().map { index, char in
            return [0, self.count - 1].contains(index) ? char : "A"
        })
    }
}

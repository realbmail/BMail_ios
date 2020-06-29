//
//  ViewController+Utils.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/26.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import MBProgressHUD

enum OpenWalletAction{
        case Cancel
        case Failed
        case Success
}

extension UIViewController {
        public struct AlertPayload {
                var title:String!
                var placeholderTxt:String?
                var securityShow:Bool = true
                var keyType:UIKeyboardType = .default
                var action:((String?, Bool)->Void)!
        }
        
        func alertMessageToast(title:String) ->Void {DispatchQueue.main.async {
            let hud : MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.detailsLabel.text = title
            hud.removeFromSuperViewOnHide = true
            hud.margin = 10
            hud.offset.y = 250.0
            hud.hide(animated: true, afterDelay: 3)
        }}

        func showIndicator(withTitle title: String, and Description:String) {DispatchQueue.main.async {
                let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
                Indicator.label.text = title
                Indicator.isUserInteractionEnabled = false
                Indicator.detailsLabel.text = Description
                Indicator.show(animated: true)
                self.view.isUserInteractionEnabled = false
        }}
        
        func hideIndicator() {DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.view.isUserInteractionEnabled = true
        }}
        
        func ShowPassword(complete:@escaping((String?, Bool) -> Void)){
               DispatchQueue.main.async {
                       let alert = UIAlertController(title: "Password Confirmation!".locStr, message: nil, preferredStyle: .alert)
                       
                       var pass_word:String? = nil
                       
                       alert.addAction(UIAlertAction(title: "Cancel".locStr, style: .cancel, handler: { action in
                               complete(nil, false)
                       }))

                       alert.addTextField(configurationHandler: { textField in
                           textField.placeholder = "Password".locStr
                       })

                       
                       alert.addAction(UIAlertAction(title: "OK".locStr, style: .default, handler: { action in
                           pass_word = alert.textFields?.first?.text
                               complete(pass_word, true)
                       }))

                       self.present(alert, animated: true)
               }
        }
        
        func ShowOneInput(title: String, placeHolder:String?, type:UIKeyboardType, nextAction:((String?, Bool)->Void)?) {
                
                let ap = AlertPayload(title: title, placeholderTxt: placeHolder, securityShow:false, keyType: type, action: nextAction)
                
                LoadAlertFromStryBoard(payload: ap)
        }
        
        func OpenWallet(title: String, placeHolder:String?, nextAction:@escaping((_ acton:OpenWalletAction)->Void)) {
                
                self.showIndicator(withTitle: "", and: "Open Wallet......".locStr)
                
                let ap = AlertPayload(title: title, placeholderTxt: placeHolder){
                        (password, isOK) in
                        guard let pwd = password, isOK else{
                                self.hideIndicator()
                                nextAction(.Cancel)
                                return
                        }
                        
                        DispatchQueue.global().async {
                                guard true == AccountManager.currentAccount!.openWallet(auth: pwd) else{
                                        self.hideIndicator()
                                        self.ShowTips(msg: "Auth Failed".locStr)
                                        nextAction(.Failed)
                                        return
                                }
                                self.hideIndicator()
                                nextAction(.Success)
                        }
                }
                
                LoadAlertFromStryBoard(payload: ap)
        }
        
        func LoadAlertFromStryBoard(payload:AlertPayload){ DispatchQueue.main.async {
                
                        guard let alertVC = instantiateViewController(storyboardName: "Main",
                                                                     viewControllerIdentifier: "OnePasswordViewControllerID")
                            as? OnePasswordViewController else{
                            return
                        }
                        
                        alertVC.payload = payload;
                        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert);
                        alertController.setValue(alertVC, forKey: "contentViewController");
                        self.present(alertController, animated: true, completion: nil);
                }
        }
        
        func ShowQRAlertView(data:String){
                guard let alertVC = instantiateViewController(storyboardName: "Main",
                                                             viewControllerIdentifier: "QRCodeShowViewControllerSID")
                    as? QRCodeShowViewController else{
                    return
                }
                
                alertVC.StringToShow = data;
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert);
                alertController.setValue(alertVC, forKey: "contentViewController");
                self.present(alertController, animated: true, completion: nil);
        }
        
        func ShowTips(msg:String){
                DispatchQueue.main.async {
                        let ac = UIAlertController(title: "Tips:".locStr, message: msg, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK".locStr, style: .default))
                        self.present(ac, animated: true)
                }
        }
        
        func showConfirm(msg:String, yesHandler:@escaping (() -> Void) , noHandler:(() -> Void)? = nil){
                
                DispatchQueue.main.async {
                        
                        let ac = UIAlertController(title: "Are you sure?".locStr, message: msg, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "YES".locStr, style: .default, handler: { (alert) in
                                yesHandler()
                        }))
                        ac.addAction(UIAlertAction(title: "NO".locStr, style: .default, handler: {(alert) in
                                noHandler?()
                        }))
                        self.present(ac, animated: true)
               }
        }
}

public func instantiateViewController(storyboardName: String, viewControllerIdentifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main);
    return storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier);
}

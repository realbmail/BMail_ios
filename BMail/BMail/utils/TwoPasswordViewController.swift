//
//  TwoPasswordViewController.swift
//  BMail
//
//  Created by wesley on 2020/8/11.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class TwoPasswordViewController: PasswordViewController {
        @IBOutlet weak var titleLab: UILabel!
        @IBOutlet weak var paswordInputTF: UITextField!
        @IBOutlet weak var paswordInputTF2: UITextField!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                self.preferredContentSize = CGSize(width: 240, height: 240)
                
                paswordInputTF.leftViewMode = UITextField.ViewMode.always
                paswordInputTF.leftView = UIView(frame:CGRect(x:0, y:0, width:18, height:10))
                paswordInputTF.isSecureTextEntry = self.payload.securityShow
                paswordInputTF.keyboardType = self.payload.keyType
                self.paswordInputTF.placeholder = payload.placeholderTxt
                
                
                paswordInputTF2.leftViewMode = UITextField.ViewMode.always
                paswordInputTF2.leftView = UIView(frame:CGRect(x:0, y:0, width:18, height:10))
                paswordInputTF2.isSecureTextEntry = self.payload.securityShow
                paswordInputTF2.keyboardType = self.payload.keyType
                self.paswordInputTF2.placeholder = payload.placeholderTxt
                
                self.titleLab.text = payload.title
        }
        
        @IBAction func OKCation(_ sender: Any) {
                let password = self.paswordInputTF.text
                let password2 = self.paswordInputTF2.text
                guard password == password2, password != "" else{
                        self.ShowTips(msg: "2 passwords are not same".locStr)
                        return
                }
                
                self.dismiss(animated: false){
                        self.payload.action(password, true)
                }
        }
        
        @IBAction func CancelAction(_ sender: Any) {
                self.dismiss(animated: false){
                        self.payload.action(nil, false)
                }
        }
}

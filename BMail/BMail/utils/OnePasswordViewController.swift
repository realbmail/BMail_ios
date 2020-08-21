//
//  OnePasswordViewController.swift
//  bpassword
//
//  Created by hyperorchid on 2020/4/5.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class OnePasswordViewController: PasswordViewController {
        
        @IBOutlet weak var titleLab: UILabel!
        @IBOutlet weak var paswordInputTF: UITextField!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                paswordInputTF.leftViewMode = UITextField.ViewMode.always
                paswordInputTF.leftView = UIView(frame:CGRect(x:0, y:0, width:18, height:10))
                paswordInputTF.isSecureTextEntry = self.payload.securityShow
                paswordInputTF.keyboardType = self.payload.keyType
                self.paswordInputTF.placeholder = payload.placeholderTxt
                
                self.titleLab.text = payload.title
        }
        
        @IBAction func OKCation(_ sender: Any) {
                let password = self.paswordInputTF.text
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

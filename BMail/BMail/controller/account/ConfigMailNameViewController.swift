//
//  ConfigMailNameViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import BmailLib

class ConfigMailNameViewController: UIViewController {

        @IBOutlet weak var hashValueOfMaillName: UILabel!
        @IBOutlet weak var bmailAddressOnBlockChain: UILabel!
        @IBOutlet weak var MailNameTF: UITextField!
        @IBOutlet weak var currentBmailAddress: UILabel!
        var gotHashValue:Bool = false
        let emailPred = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+")
        
        override func viewDidLoad() {
                super.viewDidLoad()
                self.currentBmailAddress.text = AccountManager.currentAccount!.Address()
                self.MailNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    
        @IBAction func setupMailName(_ sender: UIButton) {
                guard gotHashValue else {
                        self.ShowTips(msg: "Invalid mail name".locStr)
                        return
                }
                
                self.showIndicator(withTitle: "", and: "Verifying on blockchain".locStr)
                let current_address = self.currentBmailAddress.text
                guard let mail_name = self.MailNameTF.text else{
                        self.ShowTips(msg: "Invalid mail name".locStr)
                        return
                }
                DispatchQueue.global().async {
                        defer{
                                self.hideIndicator()
                        }
                        let (mail_addrss, _) = QueryMailAddrBy(name:mail_name)
                        guard mail_addrss == current_address else{
                                DispatchQueue.main.async {
                                        self.bmailAddressOnBlockChain.text = mail_addrss
                                }
                                self.ShowTips(msg: "This bmail name doesn't match current address".locStr)
                                return
                        }
                        
                        DispatchQueue.main.async {
                                AccountManager.currentAccount!.setBMailName(self.MailNameTF.text!)
                                AccountManager.currentAccount!.resetNameImg()
                                self.performSegue(withIdentifier: "ShowEmailAccountBackupView", sender: self)
                        }
                }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               if segue.identifier == "ShowEmailAccountBackupView"{
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        backItem.tintColor = UIColor.init(hexColorCode: "#04062E")
                        navigationItem.backBarButtonItem = backItem
               }
        }
}

extension ConfigMailNameViewController:UITextFieldDelegate{
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }
        @objc func textFieldDidChange(_ textField: UITextField) {
                NSLog(textField.text ?? "")
                
                guard let mail_str = textField.text else{
                        return
                }
                
                let mail_parts = mail_str.split(separator: "@")
                if mail_parts.count == 2{
                        if !emailPred.evaluate(with: mail_parts[0]){
                                self.hashValueOfMaillName.text = "Invalid mail name".locStr
                                return
                        }
                        
                        let hash = BmailLibCalculateHash(mail_str)
                        self.gotHashValue = true
                        self.hashValueOfMaillName.text = hash
                        NSLog(hash)
                }else{
                        self.gotHashValue = false
                        self.hashValueOfMaillName.text = "Invalid mail name".locStr
                }
        }
}

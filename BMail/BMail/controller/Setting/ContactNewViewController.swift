//
//  ContactNewViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/6/20.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import BmailLib

class ContactNewViewController: UIViewController {

        @IBOutlet weak var MailNameTF: UITextField!
        @IBOutlet weak var MailCName: UILabel!
        @IBOutlet weak var MailHash: UILabel!
        @IBOutlet weak var MailAddr: UILabel!
        
        override func viewDidLoad() {
                super.viewDidLoad()
        }
    

        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "ShowEmailAccountBackupView"{
                         let backItem = UIBarButtonItem()
                         backItem.title = ""
                         backItem.tintColor = UIColor.init(hexColorCode: "#04062E")
                         navigationItem.backBarButtonItem = backItem
                }
        }
        
        @IBAction func QueryAction(_ sender: Any) {
               let _ = checkMail()
        }
        
        @IBAction func DoneAction(_ sender: Any) {
                guard checkMail() else {
                        return
                }
                
                let contact = BmailContact.init(ma: self.MailAddr.text!,
                                                mn: self.MailNameTF.text!,
                                                dn: self.MailCName.text!)
                BmailContact.addContact(contact: contact)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true)
        }
        
        private func checkMail() -> Bool{
                guard let mail_name = self.MailNameTF.text else{
                        self.ShowTips(msg: "Invalid mail adress".locStr)
                        return false
                }
                
                guard ValidateEmail(mail_name) else {
                        self.ShowTips(msg: "Invalid mail adress".locStr)
                        return false
                }
                let hash = BmailLibCalculateHash(mail_name)
                self.MailHash.text = hash
                
                let (mail_addrss, cname) = QueryMailAddrBy(name:mail_name)
                guard mail_addrss != "" else{
                        self.ShowTips(msg: "No Blockchain record for:".locStr + mail_name)
                        return false
                }
                self.MailCName.text = cname
                self.MailAddr.text = mail_addrss
                return true
        }
}

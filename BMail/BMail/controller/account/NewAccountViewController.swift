//
//  NewAccountViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/26.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class NewAccountViewController: UIViewController {
        @IBOutlet weak var password1TF: UITextField!
        @IBOutlet weak var password2TF: UITextField!
        @IBOutlet weak var tipsLabel: UILabel!
        
        
        var imagePicker: UIImagePickerController!
        override func viewDidLoad() {
                super.viewDidLoad()
                self.navigationItem.backBarButtonItem?.title = ""
        }
            
        @IBAction func CreatAction(_ sender: UIButton) {
                
                guard password1TF.text == password2TF.text else {
                        tipsLabel.text = "The 2 passwords are not same".locStr
                        return
                }
                
                guard let pwd = password1TF.text, pwd.count >= Constants.PasswordLeastLen else {
                        tipsLabel.text = "Passowrd is less than %d characters".localize(arguments: Constants.PasswordLeastLen)
                        return
                }
                
                self.showIndicator(withTitle: "", and: "creating account......".locStr)
                DispatchQueue.global().async {
                        defer{
                                self.hideIndicator()
                        }
                        
                        guard let mail_account = BMAccount.newAccount(auth: pwd) else{
                                self.ShowTips(msg: "Create account failed".locStr)
                                return
                        }
                        
                        AccountManager.replaceActiveMail(mail_account)
                        DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "ShowBmailBlockchainAddress", sender: self)
                        }
                }
        }
        
        @IBAction func showIosHelop(_ sender: UIButton) {
                if let url = URL(string: "https://m.baschain.org/#/help/mobile-bmail-guide") {
                    UIApplication.shared.open(url)
                }
        }
        
        @IBAction func Import(_ sender: UIBarButtonItem) {
                let alert = UIAlertController(title:"", message: "Please Select an Option".locStr, preferredStyle: .actionSheet)

                alert.addAction(UIAlertAction(title: "Import QR image".locStr, style: .default , handler:{ (UIAlertAction)in
                      self.importFromLib()
                }))

                alert.addAction(UIAlertAction(title: "Scan QR Code".locStr, style: .default , handler:{ (UIAlertAction)in
                       self.importFromCamera()
                }))

                alert.addAction(UIAlertAction(title: "Cancel".locStr, style: .cancel, handler:{ (UIAlertAction)in
                  NSLog("=======>User click Dismiss button")
                }))

                alert.popoverPresentationController?.sourceView = self.view;
                alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1) //(0,0,1.0,1.0);
                self.present(alert, animated: true)
        }

        func importFromLib(){
                self.imagePicker =  UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
        }

        func importFromCamera(){
                self.performSegue(withIdentifier: "ImportAccountByScanQR", sender: self)
        }
               
               // MARK: - Navigation
               // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               if segue.identifier == "ImportAccountByScanQR"{
                        let vc : ScannerViewController = segue.destination as! ScannerViewController
                        vc.delegate = self
               }else if segue.identifier == "ShowBmailBlockchainAddress"{
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        backItem.tintColor = UIColor.init(hexColorCode: "#04062E")
                        navigationItem.backBarButtonItem = backItem
               }
        }
}

extension NewAccountViewController:UITextFieldDelegate{
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
        }
}

extension NewAccountViewController: UINavigationControllerDelegate,
                                UIImagePickerControllerDelegate,
                                ScannerViewControllerDelegate{

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
                
                imagePicker.dismiss(animated: true, completion: nil)
                guard let qrcodeImg = info[.originalImage] as? UIImage else {
                        self.ShowTips(msg: "Image not found!".locStr)
                        return
                }
                
                let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
                let ciImage:CIImage=CIImage(image:qrcodeImg)!
               
                let features=detector.features(in: ciImage)
                var codeStr = ""
                for feature in features as! [CIQRCodeFeature] {
                    codeStr += feature.messageString!
                }
                
                if codeStr == "" {
                        self.ShowTips(msg: "Parse image failed".locStr)
                        return
                }else{
                        NSLog("=======>image QR string message: \(codeStr)")
                        self.codeDetected(code: codeStr)
                }
        }
        
        func codeDetected(code: String){
                
                self.showIndicator(withTitle: "", and: "Unlcok the account......".locStr)
                
                let ap = AlertPayload(title: "Confirm ownership".locStr, placeholderTxt: "Password to unlock account".locStr){
                        (password, isOK) in
                        
                        defer {
                                self.hideIndicator()
                        }
                        guard let pwd = password, isOK else{
                                return
                        }
                        
                        NSLog("=======>importing account:[\(code)]")
                        guard let mail_account = BMAccount.init(json: code, auth: pwd) else{
                                self.ShowTips(msg: "Import account failed".locStr)
                                return
                        }
                        AccountManager.replaceActiveMail(mail_account)
                        
                        if mail_account.MailName() != nil && mail_account.MailName() != ""{
                                //TODO FIXME:: change root view controller of application
                                NSLog("=======>should change root vc")
                                UIApplication.shared.keyWindow?.rootViewController = ContainerViewController();
                        }else{
                                self.performSegue(withIdentifier: "TryConfigBmailNameAgainSeg", sender: self)
                        }
                }
                LoadAlertFromStryBoard(payload: ap)
        }
}

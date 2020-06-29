//
//  BMailAddressViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import Photos

class BMailAddressViewController: UIViewController {
        @IBOutlet weak var BMAddressTF: UILabel!
        @IBOutlet weak var QRImageView: UIImageView!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                guard let address = AccountManager.currentAccount?.Address() else{
                        self.ShowTips(msg: "BMail address is invalid".locStr)
                        return
                }
                
                BMAddressTF.text = address
                QRImageView.image = generateQRCode(from: address)
        }
    
        @IBAction func copyAddress(_ sender: Any) {
                UIPasteboard.general.string = BMAddressTF.text
                self.ShowTips(msg: "Copy Success".locStr)
        }
        
        @IBAction func next(_ sender: Any) {
                self.performSegue(withIdentifier: "ConfigBasEMaillNameSeg", sender: self)
        }
        @IBAction func showHelpView(_ sender: Any) {
                if let url = URL(string: "https://m.baschain.org/#/help/bmail-guide") {
                    UIApplication.shared.open(url)
                }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               if segue.identifier == "ConfigBasEMaillNameSeg"{
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        backItem.tintColor = UIColor.init(hexColorCode: "#04062E")
                        navigationItem.backBarButtonItem = backItem
               }
        }
}

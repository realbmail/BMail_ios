//
//  AccountHeaderVCViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/6/23.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import BmailLib

class AccountHeaderViewController: UIViewController {

        @IBOutlet weak var IDSignImg: UIImageView!
        @IBOutlet weak var MailNameLabel: UILabel!
        @IBOutlet weak var choseBtnb: UIButton!
        
        
        var account:BMAccount?
        var idx:Int = -1
        var backGroundColor = UIColor.init(r: CGFloat(4)/255, g: CGFloat(6)/255, b: CGFloat(46)/255, a: 1)
        var unselBgColor = UIColor.init(r: CGFloat(4)/255, g: CGFloat(6)/255, b: CGFloat(46)/255, a: 0.67)
        
        
        override func viewDidLoad() {
                super.viewDidLoad()
                MailNameLabel.text = account?.MailName()
                IDSignImg.image = account?.NameIconImg()
                
                if AccountManager.currentAccount == account{
                        self.view.backgroundColor = backGroundColor
                        choseBtnb.imageView?.image = UIImage.init(named: "ch-icon")
                }else{
                        self.view.backgroundColor = unselBgColor
                        choseBtnb.imageView?.image = UIImage.init(named: "unc-icon")
                }
        }
        
        func AccountData(data:BMAccount, idx:Int){
                account = data
                self.idx = idx
        }
        
        @IBAction func SelectAccount(_ sender: UIButton) {
        }
}

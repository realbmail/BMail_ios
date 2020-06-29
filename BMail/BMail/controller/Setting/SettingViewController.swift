//
//  SettingViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
        var appVersion: String? {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
        var curViewType:MailActionType = .Setting
        var delegate:CenterViewControllerDelegate?
        
        @IBOutlet weak var walletTimeoutLabel: UILabel!
        @IBOutlet weak var mailCacheSize: UILabel!
        @IBOutlet weak var versionNo: UILabel!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                versionNo.text = self.appVersion
        }
        
        override func viewWillAppear(_ animated: Bool){
                super.viewWillAppear(animated)
                walletTimeoutLabel.text = "\(SystemConf.SCInst.walletTimeOut)"+"Min".locStr
                mailCacheSize.text = "\(SystemConf.SCInst.mailCacheSize) M"
        }
    
        @IBAction func showMenu(_ sender: Any) {
                delegate?.toggleLeftPanel()
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "TImeOutSettingSEG"{
                        let setVc : SysDataSettingsTVC = segue.destination as! SysDataSettingsTVC
                        setVc.dataType = 1
                }
                if segue.identifier == "CacheSizeSettingSEG"{
                        let setVc : SysDataSettingsTVC = segue.destination as! SysDataSettingsTVC
                        setVc.dataType = 2
                }
                let backItem = UIBarButtonItem()
                backItem.title = ""
                backItem.tintColor = UIColor.init(hexColorCode: "#04062E")
                navigationItem.backBarButtonItem = backItem
        }
}

extension SettingViewController: CenterViewController{
        func changeContext(viewType: MailActionType) {
        }
        
        func setDelegate(delegate: CenterViewControllerDelegate) {
                self.delegate = delegate
        }
}

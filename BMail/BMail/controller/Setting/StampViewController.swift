//
//  StampViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/19.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class StampViewController: UIViewController {
        var curViewType:MailActionType = .Stamp
        var delegate:CenterViewControllerDelegate?
        
        
        override func viewDidLoad() {
                super.viewDidLoad()
        }
        @IBAction func showMenu(_ sender: Any) {
                delegate?.toggleLeftPanel()
        }
        
        @IBAction func OperationWallet(_ sender: UIBarButtonItem) {
        }
        
}


extension StampViewController: CenterViewController{
        func changeContext(viewType: MailActionType) {
        }
        
        func setDelegate(delegate: CenterViewControllerDelegate) {
                self.delegate = delegate
        }
}

//
//  BugReportViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class BugReportViewController: UIViewController {
        
        var curViewType:MailActionType = .BugReport
        var delegate:CenterViewControllerDelegate?
        
        override func viewDidLoad() {
                super.viewDidLoad()
        }
    
        @IBAction func showMenu(_ sender: Any) {
                delegate?.toggleLeftPanel()
        }
}

extension BugReportViewController: CenterViewController{
        func changeContext(viewType: MailActionType) {
        }
        
        func setDelegate(delegate: CenterViewControllerDelegate) {
                self.delegate = delegate
        }
}

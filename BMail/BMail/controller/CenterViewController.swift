//
//  CenterViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

protocol CenterViewControllerDelegate {
        func toggleLeftPanel()
        func collapseSidePanels()
}

protocol CenterViewController {
        func changeContext(viewType:MailActionType)
        func setDelegate(delegate:CenterViewControllerDelegate)
}

//class CenterViewController: UIViewController {
//
//        var curViewType: MailActionType = .Inbox
//        var delegate: CenterViewControllerDelegate?
//        override func viewDidLoad() {
//                super.viewDidLoad()
//        }
//
//        public  func changeContext(viewType:MailActionType) {
//                curViewType = viewType
//        }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

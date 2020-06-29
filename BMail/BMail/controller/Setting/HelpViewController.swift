//
//  HelpViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import WebKit

class HelpViewController: UIViewController, WKUIDelegate {
        
        var curViewType:MailActionType = .Help
        var delegate:CenterViewControllerDelegate?
        var webView: WKWebView!
        
        override func loadView() {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.uiDelegate = self
            view = webView
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                let myURL = URL(string:"https://m.baschain.org/")
                let myRequest = URLRequest(url: myURL!)
                webView.load(myRequest)
        }
        
        @IBAction func showMenu(_ sender: UIBarButtonItem) {
                delegate?.toggleLeftPanel()
        }
}

extension HelpViewController: CenterViewController{
        func changeContext(viewType: MailActionType) {
        }
        
        func setDelegate(delegate: CenterViewControllerDelegate) {
                self.delegate = delegate
        }
}

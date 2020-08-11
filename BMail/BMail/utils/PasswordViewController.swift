//
//  PasswordViewController.swift
//  BMail
//
//  Created by wesley on 2020/8/11.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

typealias ActionFunction = (String?, Bool)->Void

public struct AlertPayload {
        var title:String!
        var placeholderTxt:String?
        var securityShow:Bool = true
        var keyType:UIKeyboardType = .default
        var action:ActionFunction!
}

class PasswordViewController: UIViewController {
        
        public var payload:AlertPayload!
        override func viewDidLoad() {
                super.viewDidLoad()
        }
}

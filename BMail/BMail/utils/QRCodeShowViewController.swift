//
//  QRCodeShowViewController.swift
//  bpassword
//
//  Created by hyperorchid on 2020/3/24.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class QRCodeShowViewController: UIViewController {
        
        @IBOutlet weak var Image: UIImageView!
        public var StringToShow:String?
        override func viewDidLoad() {
                super.viewDidLoad()
                self.view.layer.cornerRadius = 16
                
                guard let w_json = StringToShow else{
                        self.ShowTips(msg: "Empty Data".locStr)
                        return
                }
                self.showIndicator(withTitle: "", and: "Generating QR Code Image".locStr)
                DispatchQueue.global().async {
                        let image_data = generateQRCode(from: w_json)
                        DispatchQueue.main.async {
                                self.Image.image = image_data
                                self.hideIndicator()
                        }
                }
        }
        @IBAction func CloseWindows(_ sender: Any) {
                self.dismiss(animated: true)
        }
}

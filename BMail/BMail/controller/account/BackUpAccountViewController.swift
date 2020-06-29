//
//  BackUpAccountViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import Photos

class BackUpAccountViewController: UIViewController {

        @IBOutlet weak var QRView: UIView!
        @IBOutlet weak var cipherView: UIView!
        @IBOutlet weak var segmentedControl: UISegmentedControl!
        @IBOutlet weak var CipherTextView: UITextView!
        @IBOutlet weak var QRCodeImageVIew: UIImageView!
        @IBOutlet weak var QRUnderlineView: UIView!
        @IBOutlet weak var CipherTextUnderLineView: UIView!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                guard let cipher_txt = AccountManager.currentAccount!.CipherTxt() else{
                        return
                }

                self.CipherTextView.text = cipher_txt
                self.QRCodeImageVIew.image = generateQRCode(from: cipher_txt)
                
                segmentedControl.setTitleTextAttributes([
                        NSAttributedString.Key.foregroundColor: UIColor.init(hexColorCode: "#F28552")
                ], for: .selected)
                
        }
    
        @IBAction func exportQR(_ sender: Any) {
                PHPhotoLibrary.requestAuthorization { (status) in
                        
                        guard status == .authorized else{
                                self.showConfirm(msg: "Please authorize photo lib access".locStr, yesHandler: {
                                        if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(appSettings as URL)
                                        }
                                })
                                
                                return
                        }
                }
                
                
                self.showIndicator(withTitle: "", and: "Saving......".locStr)
                let image = self.QRCodeImageVIew.image!
                DispatchQueue.global().async {
                        defer {
                                self.hideIndicator()
                        }
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }                
        }
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
                if let error = error {
                        self.ShowTips(msg: error.localizedDescription)
                } else {
                        self.ShowTips(msg: "Save success to photo library".locStr)
                }
        }
        
        @IBAction func copyCipher(_ sender: Any) {
                UIPasteboard.general.string = CipherTextView.text
                self.ShowTips(msg: "Copy Success".locStr)
        }
        
        @IBAction func ChangeMode(_ sender: UISegmentedControl) {
                let isFirstSelected = sender.selectedSegmentIndex == 0
                cipherView.isHidden = isFirstSelected
                CipherTextUnderLineView.isHidden = isFirstSelected
                QRView.isHidden = !isFirstSelected
                QRUnderlineView.isHidden = !isFirstSelected
        }
        
        @IBAction func finish(_ sender: Any) {
                UIApplication.shared.keyWindow?.rootViewController = ContainerViewController();
        }
}

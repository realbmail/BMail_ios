//
//  AccountSettingCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import Photos

class AccountSettingCell: UITableViewCell {

        @IBOutlet weak var mailName: UILabel!
        @IBOutlet weak var mailAddress: UILabel!
        @IBOutlet weak var nickName: UILabel!
        @IBOutlet weak var configChangeBtn: UIButton!
        
        
        
        var curMailData:BMAccount!
        var parentVC:UIViewController!
        
        override func awakeFromNib() {
                super.awakeFromNib()
                // Initialization code
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
                super.setSelected(selected, animated: animated)

                // Configure the view for the selected state
        }
        
        
        func fullFill(data:BMAccount, id:Int) {
                curMailData = data
                self.tag = id
                configChangeBtn.tag = id
                self.mailName.text = data.MailName()
                self.mailAddress.text = data.Address()
                self.nickName.text = data.NickName()
        }
        
        @IBAction func BackUpAccount(_ sender: UIButton) {
                
                PHPhotoLibrary.requestAuthorization { (status) in
                        
                        guard status == .authorized else{
                                self.parentVC.showConfirm(msg: "Please authorize photo lib access".locStr, yesHandler: {
                                        if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(appSettings as URL)
                                        }
                                })
                                return
                        }
                }
                
                self.parentVC.showIndicator(withTitle: "", and: "Saving......".locStr)
                let image = generateQRCode(from: (self.curMailData.JsonString()))
                DispatchQueue.global().async {
                        defer {
                                self.parentVC.hideIndicator()
                        }
                        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
        }
        
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
                if let error = error {
                        self.parentVC.ShowTips(msg: error.localizedDescription)
                } else {
                        self.parentVC.ShowTips(msg: "Save success to photo library".locStr)
                }
        }
        
        
        @IBAction func ShowQRCode(_ sender: UIButton) {
                self.parentVC.ShowQRAlertView(data: self.mailAddress.text!)
        }
        
        @IBAction func DeleteAccount(_ sender: UIButton) {
        }
}

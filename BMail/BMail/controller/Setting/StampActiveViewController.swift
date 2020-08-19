//
//  StampActiveViewController.swift
//  BMail
//
//  Created by wesley on 2020/8/19.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class StampActiveViewController: UIViewController {

        var stamp:Stamp?
        
        @IBOutlet weak var CurentBalanceLab: UILabel!
        @IBOutlet weak var AmountToActiveFld: UITextField!
        @IBOutlet weak var PasswordFld: UITextField!
        
        @IBAction func ActiveAction(_ sender: UIButton) {
                guard let amount = Int64(AmountToActiveFld.text ?? "0"), amount < stamp!.Balance else {
                        return
                }
                
                guard let password = PasswordFld.text else {
                        return
                }
                
                self.showIndicator(withTitle: "", and: "Open walllet......")
                DispatchQueue.global(qos: .background).async {
                        defer{
                                self.hideIndicator()
                        }
                        guard StampWallet.CurSWallet.openWallet(auth: password) else{
                                self.ShowTips(msg: "Open wallet failed")
                                return
                        }
                        do {
                                try StampWallet.ActiveBalance(amount: amount, tokenAddr: self.stamp!.ContractAddr)
                                
                        } catch let err{
                                self.ShowTips(msg: err.localizedDescription)
                                return
                        }
                        self.ShowTips(msg: "Active success"){
                                _ in

                                self.navigationController?.popViewController(animated: true)
                                self.dismiss(animated: true){
                                        NotificationCenter.default.post(name: Constants.NOTI_SYSTEM_STAMP_ACTIVED, object: self.stamp?.ContractAddr)
                                }
                        }
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                CurentBalanceLab.text = "\(stamp?.Balance ?? 0)"
        }
}

//
//  StampViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/19.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class StampViewController: UIViewController {
        @IBOutlet weak var WalletAddresLbl: UILabel!
        @IBOutlet weak var WalletEthBalanceLbl: UILabel!
        @IBOutlet weak var StampAvailableTableView: UITableView!
        @IBOutlet weak var rightBarBtnItem: UIBarButtonItem!
        
        var stampAvailable:[Stamp] = []
        var curViewType:MailActionType = .Stamp
        var delegate:CenterViewControllerDelegate?
        var inUsedPath:IndexPath?
        
        override func viewDidLoad() {
                super.viewDidLoad()
                StampAvailableTableView.rowHeight = 192
                stampAvailable = Stamp.StampArray()
                
                if StampWallet.CurSWallet.isEmpty(){
                        rightBarBtnItem.image = UIImage.init(named: "add-icon")
                        WalletAddresLbl.text = ""
                        WalletEthBalanceLbl.text = "0.0 eth"
                }else{
                        rightBarBtnItem.image = UIImage.init(named: "redo")
                        WalletAddresLbl.text = StampWallet.CurSWallet.Address!
                        WalletEthBalanceLbl.text = "\(StampWallet.CurSWallet.Balance.ToCoin()) eth"
                }
        }
        @IBAction func showMenu(_ sender: Any) {
                delegate?.toggleLeftPanel()
        }
        
        @IBAction func OperationWallet(_ sender: UIBarButtonItem) {
                if WalletAddresLbl.text == ""{
                        self.showIndicator(withTitle: "", and: "Creating Stamp Wallet".locStr)
                        self.ShowOneInput(title: "New Wallet".locStr,
                                          placeHolder: "Password".locStr,
                                          type: .default) {
                                                
                                (password, isOK) in
                                defer{ self.hideIndicator()}
                                guard let pwd = password, isOK else{ return }
                                StampWallet.NewWallet(auth: pwd)
                       }
                }else{
                        self.showIndicator(withTitle: "", and: "Loading")
                        DispatchQueue.global(qos: .background).async {
                                StampWallet.CurSWallet.loadBalance()
                                DispatchQueue.main.async {
                                        self.hideIndicator()
                                        self.WalletEthBalanceLbl.text = "\(StampWallet.CurSWallet.Balance.ToCoin()) eth"
                                }
                        }
                }
        }
        
        @IBAction func showStampWalletQR(_ sender: UIButton) {
                guard  let address = self.WalletAddresLbl.text else {
                        self.ShowTips(msg: "No valid stamp wallet".locStr)
                        return
                }
                self.ShowQRAlertView(data: address)
        }
}


extension StampViewController: CenterViewController{
        func changeContext(viewType: MailActionType) {
        }
        
        func setDelegate(delegate: CenterViewControllerDelegate) {
                self.delegate = delegate
        }
}

extension StampViewController: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return stampAvailable.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StampItemCellID", for: indexPath) as! StampTableViewCell
                let s = stampAvailable[indexPath.row]
                cell.populate(stamp:s)
                if s.IsInused{
                        self.inUsedPath = indexPath
                }
                return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let s = stampAvailable[indexPath.row]
                s.IsInused = true
                var need_reload = [indexPath]
                if let path = self.inUsedPath{
                        let s_old = stampAvailable[path.row]
                        s_old.IsInused = false
                        need_reload.append(path)
                }
                
                tableView.reloadRows(at: need_reload, with: .none)
        }
}

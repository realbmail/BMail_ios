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
        @IBOutlet weak var EthBGView: UIView!
        
        var refreshControl: UIRefreshControl! = UIRefreshControl()
        var stampAvailable:[Stamp] = []
        var curViewType:MailActionType = .Stamp
        var delegate:CenterViewControllerDelegate?
        var inUsedPath:IndexPath?
        
        override func viewDidLoad() {
                super.viewDidLoad()
                StampAvailableTableView.rowHeight = 192
                StampWallet.LoadWallet()
                Stamp.LoadStampDataFromCache()
                refreshControl.tintColor = UIColor.red
                refreshControl.addTarget(self, action: #selector(self.QueryStampFromServer(_:)), for: .valueChanged)
                StampAvailableTableView.addSubview(refreshControl)
                
                stampAvailable = Stamp.StampArray()
                
                let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
                tapGR.numberOfTapsRequired = 2
                tapGR.numberOfTouchesRequired = 1
                EthBGView.addGestureRecognizer(tapGR)
                
                if StampWallet.CurSWallet.isEmpty(){
                        rightBarBtnItem.image = UIImage.init(named: "add-icon")
                        WalletAddresLbl.text = ""
                        WalletEthBalanceLbl.text = "0.0 eth"
                }else{
                        rightBarBtnItem.image = UIImage.init(named: "fresh-icon")
                        WalletAddresLbl.text = StampWallet.CurSWallet.Address!
                        WalletEthBalanceLbl.text = "\(StampWallet.CurSWallet.Balance.ToCoin()) eth"
                }
        }
        
        @objc func handleTap() {
                guard  WalletAddresLbl.text != "" else{
                        return
                }
                
                UIPasteboard.general.string = WalletAddresLbl.text
                self.ShowTips(msg: "Copy Success".locStr)
        }
        
        @objc func QueryStampFromServer(_ sender: UIRefreshControl) {
                DispatchQueue.global(qos: .background).async {
                        Stamp.LoadAvailableStampAddressFromDomainOwner()
                        DispatchQueue.main.async {
                                self.refreshControl.endRefreshing()
                                self.stampAvailable = Stamp.StampArray()
                                self.StampAvailableTableView.reloadData()
                        }
                }
        }
        
        @IBAction func showMenu(_ sender: Any) {
                delegate?.toggleLeftPanel()
        }
        
        @IBAction func OperationWallet(_ sender: UIBarButtonItem) {
                if WalletAddresLbl.text == ""{
                        self.showIndicator(withTitle: "", and: "Creating Stamp Wallet".locStr)
                        self.ShowTwoInput(title: "New Stamp Wallet".locStr,
                                          placeHolder: "Password".locStr,
                                          type: .default) {
                                (password, isOK) in
                                
                                defer{ self.hideIndicator()}
                                guard let pwd = password, isOK else{ return }
                                guard StampWallet.NewWallet(auth: pwd) else{
                                        self.ShowTips(msg: "create wallet failed")
                                        return
                                }
                                self.ShowTips(msg: "Success")
                                DispatchQueue.main.async {
                                        self.rightBarBtnItem.image = UIImage.init(named: "fresh-icon")
                                        self.WalletAddresLbl.text = StampWallet.CurSWallet.Address!
                                }
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
        
        @IBAction func activeStampBalance(_ sender: UIButton) {
                let stamp = stampAvailable[sender.tag]
                guard let contract_address = stamp.ContractAddr else{
                        return
                }
                
                self.ShowOneInput(title: "Active Stamp", placeHolder: "amount to active", type: .numberPad) {
                        (amountStr, isOK) in
                        guard let amount = Int64(amountStr ?? "0"), isOK, amount > 0 else{
                                return
                        }
                        guard amount <= stamp.Balance else{
                                self.ShowTips(msg: "Balance is not enough to active")
                                return
                        }
                        do {
                                try StampWallet.ActiveBalance(amount: amount, tokenAddr: contract_address)
                        }catch let err{
                                self.ShowTips(msg: err.localizedDescription)
                        }
                }
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
                cell.populate(stamp:s, idx: indexPath.row)
                if s.IsInUse{
                        self.inUsedPath = indexPath
                }
                return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let s = stampAvailable[indexPath.row]
                s.IsInUse = true
                var need_reload = [indexPath]
                if let path = self.inUsedPath{
                        let s_old = stampAvailable[path.row]
                        s_old.IsInUse = false
                        need_reload.append(path)
                }
                
                tableView.reloadRows(at: need_reload, with: .none)
        }
}

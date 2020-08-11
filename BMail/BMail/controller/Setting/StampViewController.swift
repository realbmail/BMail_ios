//
//  StampViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/19.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class StampViewController: UIViewController {
        @IBOutlet weak var AddWalletBarBtn: UIBarButtonItem!
        @IBOutlet weak var WalletAddresLbl: UILabel!
        @IBOutlet weak var WalletEthBalanceLbl: UILabel!
        @IBOutlet weak var StampAvailableTableView: UITableView!
        
        var stampAvailable:[Stamp] = []
        var curViewType:MailActionType = .Stamp
        var delegate:CenterViewControllerDelegate?
        var inUsedPath:IndexPath?
        
        override func viewDidLoad() {
                super.viewDidLoad()
                StampAvailableTableView.rowHeight = 192
                stampAvailable = Stamp.StampArray()
        }
        @IBAction func showMenu(_ sender: Any) {
                delegate?.toggleLeftPanel()
        }
        
        @IBAction func OperationWallet(_ sender: UIBarButtonItem) {
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

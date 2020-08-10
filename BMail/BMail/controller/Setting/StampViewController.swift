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
        
        override func viewDidLoad() {
                super.viewDidLoad()
                StampAvailableTableView.rowHeight = 180
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
                return cell
        }
}

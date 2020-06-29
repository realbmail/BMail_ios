//
//  MenuViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/25.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

protocol SidePanelViewControllerDelegate {
        func actionByViewType(viewType:MailActionType)
}

class MenuViewController: UIViewController {
        var delegate: SidePanelViewControllerDelegate?
        private let kMenuTableCellId: String  = "menu_table_cell"
        private let kLabelTableCellId: String = "menu_label_cell"
        
        @IBOutlet weak var headerView: UIView!
        @IBOutlet weak var nickNameLable: UILabel!
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var bmailAddressLabel: UILabel!
        @IBOutlet weak var mailNameLabel: UILabel!
        @IBOutlet weak var mailNameIcon: UIImageView!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapMailAddress(_:)))
                headerView.addGestureRecognizer(tap)
                NotificationCenter.default.addObserver(self, selector:
                                                #selector(ActiveMailChanged(_:)),
                                                       name: Constants.NOTI_SYSTEM_ACTIVE_MAIL_CHANGED,
                                                       object: nil)
        }
        
        @objc func tapMailAddress(_ gestureRecognizer:UITapGestureRecognizer){
                UIPasteboard.general.string = bmailAddressLabel.text
                self.ShowTips(msg: "Copy Success".locStr)
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                guard let active_mail = AccountManager.currentAccount else{
                        //forward to new coount
                        return
                }
                guard let mail_name = active_mail.MailName(), mail_name != "" else {
                       //forward to config page
                       return
                }

                self.bmailAddressLabel.text = active_mail.Address()
                self.mailNameLabel.text = active_mail.MailName()
                self.mailNameIcon.image = active_mail.NameIconImg()
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        @objc func ActiveMailChanged(_ notification: Notification?) {
        }
}

extension MenuViewController:UITableViewDataSource{
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                switch section {
                case 0:
                    return 4
                case 1:
                    return 5
                case 2:
                    return 0
                default:
                    return 0
                }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let row = indexPath.row
                let s = indexPath.section
                let cell = tableView.dequeueReusableCell(withIdentifier: kMenuTableCellId, for: indexPath) as! MenuTableViewCell
                cell.configCell(row, section:s)
                cell.configUnreadCount()
                return cell
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
                return 2
        }
}

extension MenuViewController:UITableViewDelegate{
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
                let x = indexPath.section * MailActionType.Help.rawValue + indexPath.row
                let actionType = MailActionType(rawValue: x)!
                self.delegate?.actionByViewType(viewType: actionType)
        }

        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            switch section {
            case 0:
                return 6.0
            case 1:
                return 1.0
            default:
                return 0.0
            }
        }
}

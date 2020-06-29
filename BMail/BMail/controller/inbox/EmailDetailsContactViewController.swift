//
//  EmailDetailsContactViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/6/23.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class EmailDetailsContactViewController: UIViewController {

        @IBOutlet weak var FromContacts: UILabel!
        @IBOutlet weak var ContactsTableView: UITableView!
        
        var FromMail:String?
        var Tos:[Receipt] = []
        var CCs:[Receipt] = []
        var BCCs:[Receipt] = []
        
        override func viewDidLoad() {
                super.viewDidLoad()
                self.FromContacts.text = FromMail
        }
}

extension EmailDetailsContactViewController: UITableViewDelegate, UITableViewDataSource{
        
        func numberOfSections(in tableView: UITableView) -> Int {
                return 3
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                switch section {
                case 0:
                        return Tos.count
                case 1:
                        return CCs.count
                case 2:
                        return BCCs.count
                default:
                        return 0
                }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                var r:Receipt!
                switch indexPath.section {
                case 0:
                        r = Tos[indexPath.row]
                case 1:
                        r = CCs[indexPath.row]
                case 2:
                        r = BCCs[indexPath.row]
                default:
                        r = Tos[indexPath.row]
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCellInEmailDetailsID")!
                if r.displayName == nil{
                        let contact = BmailContact.QueryAddress(mailName: r.mailName)
                        r.displayName = contact?.DisplayName
                }
                cell.textLabel?.text = r.displayName
                cell.detailTextLabel?.text = r.mailName
                
                return cell
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                switch section {
                case 0:
                        return "TO".locStr
                case 1:
                        return "CC".locStr
                case 2:
                        return "BCC".locStr
                default:
                        return "RCPTs:"
                }
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 24
        }
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return 12
        }
}

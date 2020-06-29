//
//  AccountSettingViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class AccountSettingViewController: UIViewController {
    
        var hiddenSections = Set<Int>()
        
        var addItemBarBtn: UIBarButtonItem!
        var curViewType:MailActionType = .Inbox
        var delegate:CenterViewControllerDelegate?
        
        @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                self.tableView.rowHeight = 188
                addItemBarBtn = UIBarButtonItem(image: UIImage.init(named: "add-icon"),
                                               style: UIBarButtonItem.Style.plain,
                                               target: self,
                                               action: #selector(NewAccountAction))
                
//                let rightButtons:[UIBarButtonItem] = [addItemBarBtn]
//                self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        }
    
        @objc internal func NewAccountAction(_ sender: UIBarButtonItem) {
                self.performSegue(withIdentifier: "CreateAccountFromManagerVIew", sender: self)
        }
        
        
        @IBAction func MenuAction(_ sender: UIBarButtonItem) {
                delegate?.toggleLeftPanel()
        }
        
        @IBAction func ChangeMailConfig(_ sender: UIButton) {
                self.performSegue(withIdentifier: "ChangeConfigFromManagerVIew", sender: self)
        }
        
        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                let backItem = UIBarButtonItem()
                backItem.title = ""
                backItem.tintColor = UIColor.init(hexColorCode: "#04062E")
                navigationItem.backBarButtonItem = backItem
        }

}

extension AccountSettingViewController:UITableViewDataSource, UITableViewDelegate{
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if self.hiddenSections.contains(section) {
                    return 0
                }
                
                return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSettingCell") as! AccountSettingCell
                let account = AccountManager.mailAccounts[indexPath.section]
                cell.fullFill(data:account, id: indexPath.section)
                cell.parentVC = self
                return cell
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
                return AccountManager.mailAccounts.count
        }
        
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let accountHeaderVC = UIStoryboard.viewController(name: "AccountHeaderViewController") as! AccountHeaderViewController
                
                let account = AccountManager.mailAccounts[section]
                accountHeaderVC.AccountData(data: account, idx: section)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideSection(_:)))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                accountHeaderVC.view.addGestureRecognizer(tapGesture)
                accountHeaderVC.view.tag = section
                return accountHeaderVC.view
        }
        
        @objc
        private func hideSection(_ sender: UITapGestureRecognizer) {
                let section = sender.view!.tag
                func indexPathsForSection() -> [IndexPath] {
                        var indexPaths = [IndexPath]()
                        indexPaths.append(IndexPath(row: 0, section: section))
                        return indexPaths
                }
                
                if self.hiddenSections.contains(section) {
                        self.hiddenSections.remove(section)
                        self.tableView.insertRows(at: indexPathsForSection(),
                                          with: .fade)
                } else {
                        self.hiddenSections.insert(section)
                        self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
                }
        }
}

extension AccountSettingViewController: CenterViewController{
        
        func changeContext(viewType: MailActionType) {
        }
        
        func setDelegate(delegate:CenterViewControllerDelegate){
                self.delegate = delegate
        }
        
}

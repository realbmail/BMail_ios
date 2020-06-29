//
//  ReceivedMailViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/18.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

protocol EmailDetailDelegate {
        func reloadMailList()
}

class EmailDetailViewController: UIViewController {
        
        let ESTIMATED_ROW_HEIGHT : CGFloat = 75
        let ESTIMATED_SECTION_HEADER_HEIGHT : CGFloat = 50
        let CONTACTS_BASE_HEIGHT = 56
        let CONTACTS_MAX_HEIGHT: CGFloat = 300.0
        let CONTACTS_ROW_HEIGHT = 28
        
        @IBOutlet weak var EmailTableViews: UITableView!
        @IBOutlet weak var FooterCell: EmailDetailFooterCell!
     
        private var removeBarButtonItem: UIBarButtonItem!
        private var decryptBarButtonItem: UIBarButtonItem!
        private var unreadBarButtonItem: UIBarButtonItem!
        private var moreBarButtonItem: UIBarButtonItem!
        
        var HeaderCell: EmailDetailHeaderCell?
        var MailInSameSubject:[EnvelopeEntity] = []
        var SelMail:EnvelopeEntity!
        var curType:MailActionType!
        var delegate:EmailDetailDelegate?
        var mailIdx:Int?
        var actionType:ComposeMailViewController.ActionType?
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.configureNavigationBar()
                
                EmailTableViews.sectionHeaderHeight = UITableView.automaticDimension
                EmailTableViews.estimatedSectionHeaderHeight = ESTIMATED_SECTION_HEADER_HEIGHT;
                EmailTableViews.rowHeight = UITableView.automaticDimension
                EmailTableViews.estimatedRowHeight = ESTIMATED_ROW_HEIGHT
                let headerNib = UINib(nibName: "EmailDetailHeaderCell", bundle: nil)
                EmailTableViews.register(headerNib, forHeaderFooterViewReuseIdentifier: "EmailDetailHeaderCell")
                MailInSameSubject.append(SelMail)//TODO::
                
                FooterCell.isHidden = curType != .Inbox
                
                if SelMail.isDecrypted{
                        decryptBarButtonItem.image = UIImage.init(named: "open-block-icon")
                }
        }
        
        func configureNavigationBar() {
                let tint_color = UIColor.init(hexColorCode: "#222020")
                
                removeBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_trash"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(RemoveMail))
                removeBarButtonItem.tintColor = tint_color
                
                unreadBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "mark_read"),//mark_read
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(UnreadMail))
                unreadBarButtonItem.tintColor = tint_color
                                                      
                decryptBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "block-icon"),//block-icon//open-block-icon
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(DecryptMail))
                decryptBarButtonItem.tintColor = tint_color
                                                                                      
                moreBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_more"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(MoreAction))
                moreBarButtonItem.tintColor = tint_color
                
                self.navigationController?.navigationBar.tintColor = UIColor.white
                var rightButtons:[UIBarButtonItem] = []
                switch curType {
                case .Inbox, .Recycle:
                        rightButtons = [unreadBarButtonItem, decryptBarButtonItem]
                        break
                case .Sent:
                        rightButtons = [decryptBarButtonItem]
                        break
                default:
                        break
                }
                self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
                self.setNeedsStatusBarAppearanceUpdate()
        }
        
        @objc internal  func UnreadMail(_ sender: UIBarButtonItem) {
                if SelMail?.isUnread == true{
                         SelMail?.isUnread = false
                         unreadBarButtonItem.image = UIImage.init(named: "mark_read")
                }else{
                        SelMail?.isUnread = true
                        let _ = SelMail?.store()
                        unreadBarButtonItem.image = UIImage.init(named: "mark_unread")
                }

                let _ = SelMail?.store()
                MailManager.reloadCounter(typ: .Inbox)
                self.delegate?.reloadMailList()
        }
        
        
        @objc internal  func DecryptMail(_ sender: UIBarButtonItem) {
                guard let account = AccountManager.currentAccount else {return}
                guard account.isOpen() else {
                       
                        self.showIndicator(withTitle: "", and: "Unlcok the account......".locStr)
                       
                        self.ShowOneInput(title: "Mail Account".locStr, placeHolder: "Password".locStr, type: .default) { (password, isOK) in
                               defer{ self.hideIndicator()}
                               guard let pwd = password, isOK else{ return }
                               
                               guard account.openWallet(auth: pwd) else{
                                self.ShowTips(msg: "Failed to open mail account".locStr)
                                       return
                               }
                        }
                        return
               }
                
                if SelMail.isDecrypted{
                        self.HeaderCell?.setSubject(self.MailInSameSubject[0].rawSubject ?? "No Subject".locStr)
                        sender.image = UIImage.init(named: "block-icon")
                        SelMail.isDecrypted = false
                        self.EmailTableViews.reloadData()
                }else{
                        for m in MailInSameSubject{
                                m.DecryptByPinCode()
                        }
                        self.EmailTableViews.reloadData()
                        self.HeaderCell?.setSubject(self.MailInSameSubject[0].rawSubject ?? "No Subject".locStr)
                        sender.image = UIImage.init(named: "open-block-icon")
                        SelMail.isDecrypted = true
                }
                self.delegate?.reloadMailList()
        }
        
        @objc internal  func RemoveMail(_ sender: UIBarButtonItem) {
        }
        
        @objc internal  func MoreAction(_ sender: UIBarButtonItem) {
        }
    
        @IBAction func BackAction(_ sender: UIBarButtonItem) {
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
        }
        
        @IBAction func OndeleteAction(_ sender: UIButton) {
                
                if curType == .Recycle{
                        MailManager.removeAtIndex(self.mailIdx!)
                }else{
                        MailManager.trashAtIndex(self.mailIdx!)
                }
                
                self.delegate?.reloadMailList()
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil) 
        }
        
        func gotoCompose() {
                guard SelMail.isDecrypted else {
                        self.ShowTips(msg: "Decrypted the mail first please".locStr)
                        return
                }
                self.performSegue(withIdentifier: "ComposeNewMailFromEmailSEG", sender: self)
        }
        
        @IBAction func ReplyAllAction(_ sender: ReplyDetailUIView) {
                self.actionType = .ReplyAll
                gotoCompose()
        }
        @IBAction func ReplyAction(_ sender: ReplyDetailUIView) {
                self.actionType = .Reply
                gotoCompose()
        }
        @IBAction func OnPressForward(_ sender: ReplyDetailUIView) {
                self.actionType = .Forward
                gotoCompose()
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "ComposeNewMailFromEmailSEG"{
                        let navVC : UINavigationController = segue.destination as! UINavigationController
                        let vc = navVC.viewControllers.first as! ComposeMailViewController
                        vc.delegate = (self.delegate as! ComposerSendMailDelegate)
                        vc.currentMail = SelMail
                        vc.actionType = self.actionType
               }
       }
}

extension EmailDetailViewController:UITableViewDelegate, UITableViewDataSource{
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                guard HeaderCell == nil else {
                    return HeaderCell
                }
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EmailDetailHeaderCell") as! EmailDetailHeaderCell
//                headerView.addLabels()
                if SelMail.isDecrypted{
                        headerView.setSubject(MailInSameSubject[0].rawSubject ?? "No Subject".locStr)
                }else{
                        headerView.setSubject(MailInSameSubject[0].pinCodedSub ?? "No Subject".locStr)
                }
//                headerView.onStarPressed = { [weak self] in
//                    self?.onStarPressed()
//                }
                HeaderCell = headerView
                return HeaderCell
        }
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                return FooterCell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return MailInSameSubject.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmailDetailsTableViewCell", for: indexPath) as! EmailDetailsTableViewCell
                cell.setupContent(mail: MailInSameSubject[indexPath.row])
                cell.delegate = self
                return cell
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                return FooterCell.frame.size.height
        }
}

extension EmailDetailViewController:MailCellActionDelegate, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate{
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
                return UIModalPresentationStyle.none
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
        {
            return UIModalPresentationStyle.none
        }
        
        func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
                return .none
        }

        func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
                return true
        }
        
        func popoverContacts(_ mail: EnvelopeEntity, _ sender: UIView){
                
                let optionsVC = UIStoryboard.viewController(name: "EmailDetailsContactViewController") as! EmailDetailsContactViewController
                optionsVC.FromMail = mail.fromName
                optionsVC.Tos = Array(mail.Tos.values)
                optionsVC.CCs = Array(mail.CCs.values)
                if self.curType == .Sent{
                        optionsVC.BCCs = Array(mail.BCCs.values)
                }
                
                optionsVC.modalPresentationStyle = .popover
                
                if let popover = optionsVC.popoverPresentationController {
                        popover.sourceView = sender
                        let p = sender.superview?.convert(sender.center, to: self.view)
                        popover.sourceRect = CGRect.init(origin: p!, size: CGSize.init(width: -10, height: -10))
                        popover.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
                        optionsVC.preferredContentSize = CGSize(width: 240, height: 320)
                        popover.delegate = self
                }
                
                self.present(optionsVC, animated: true)
        }
        
        func showOperationsForMail(_ cell: EmailDetailsTableViewCell, _ sender: UIView){
                guard let indexPath = EmailTableViews.indexPath(for: cell) else {
                        return
                }
                
                let mail = MailInSameSubject[indexPath.row]
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                           
                alert.addAction(UIAlertAction(title: "Delete".locStr, style: .default , handler:{ (UIAlertAction)in
                        mail.markAs(typ: .Recycle)
                }))

                alert.addAction(UIAlertAction(title: "Mark as Spam".locStr, style: .default , handler:{ (UIAlertAction)in
                        mail.markAs(typ:.Spam)
                }))

                alert.addAction(UIAlertAction(title: "Mark as Unread".locStr, style: .default , handler:{ (UIAlertAction)in
                        mail.markAsUnread()
                }))

                alert.addAction(UIAlertAction(title: "Cancel".locStr, style: .cancel))

                alert.popoverPresentationController?.sourceView = sender;
                alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: sender.frame.size.width/1.0001, height: sender.frame.size.height) //(0,0,1.0,1.0);
                self.present(alert, animated: true)
        }
        
        func tableViewReload(_ cell: EmailDetailsTableViewCell) {
                self.EmailTableViews.reloadData()
        }
}

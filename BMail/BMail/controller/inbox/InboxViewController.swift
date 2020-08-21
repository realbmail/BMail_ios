//
//  MasterViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/24.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import CoreData
import BmailLib

class MailSenderPoper: NSObject, BmailLibMailCallBackProtocol{
        var parent:UIViewController
        var action:Int = 0
        init(vc:UIViewController) {
                parent = vc
        }
        
        func process(_ typ: Int, msg: String?) {
                
                print("----tye[\(typ)] msg[\(msg ?? "<->")]")
                if typ == 0{
                        guard let message = msg else { return }
                        parent.alertMessageToast(title: message )
                }else{
                        parent.ShowTips(msg: msg ?? "<->")
                }
        }
}

class InboxViewController: UIViewController{
        
//        private var composeBarButtonItem:UIBarButtonItem!
        private var searchBarButtonItem: UIBarButtonItem!
        private var removeBarButtonItem: UIBarButtonItem!
        private var labelBarButtonItem: UIBarButtonItem!
        private var folderBarButtonItem: UIBarButtonItem!
        private var unreadBarButtonItem: UIBarButtonItem!
        private var moreBarButtonItem: UIBarButtonItem!
        private var decrypteButtonItem: UIBarButtonItem!
        
        @IBOutlet weak var compseBtn: UIButton!
        @IBOutlet weak var noMessageTipsView: UILabel!
        @IBOutlet weak var envelopTableView: UITableView!
        @IBOutlet weak var BottomMsg: UIView!
        
        var refreshControl: UIRefreshControl! = UIRefreshControl()
        private var curSelectedMail:EnvelopeEntity?
        private var curSelectedMailIdx:Int?
        let mailOpQueue = DispatchQueue.init(label: "mail loading queue")
        var curViewType:MailActionType = .Inbox
        var delegate:CenterViewControllerDelegate?
        var mailHelper:MailSenderPoper!
        var isDecrypted:Bool = false
        
        override func viewDidLoad() {
                super.viewDidLoad()
                mailHelper = MailSenderPoper.init(vc: self)
                
                envelopTableView.rowHeight = 62
                refreshControl.tintColor = UIColor.red
                refreshControl.addTarget(self, action: #selector(self.BPopMailFromServer(_:)), for: .valueChanged)
                envelopTableView.addSubview(refreshControl)
                
                let tint_color = UIColor.init(hexColorCode: "#222020")
//                composeBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_compose"),
//                                                style: UIBarButtonItem.Style.plain,
//                                                target: self,
//                                                action: #selector(NewMailAction))
                
                searchBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_search"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(SearchMailAction))
                searchBarButtonItem.tintColor = tint_color
                                                      
                removeBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_trash"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(RemoveMail))
                removeBarButtonItem.tintColor = tint_color
                                                
                labelBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_label"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(LabelMail))
                labelBarButtonItem.tintColor = tint_color
                
                folderBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_folder"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(foldMail))
                folderBarButtonItem.tintColor = tint_color
                                                      
                unreadBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "mark_read"),//mark_unread
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(UnreadMail))
                unreadBarButtonItem.tintColor = tint_color
                                                                                      
                moreBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "top_more"),
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(MoreAction))
                moreBarButtonItem.tintColor = tint_color
                
                decrypteButtonItem = UIBarButtonItem(image: UIImage.init(named: "block-icon"),//open-block-icon
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(DecryptMailList))
                
                decrypteButtonItem.tintColor = tint_color
                self.configureNavigationBar()
                self.changeContext(viewType: .Inbox)
        }
        //MARK: - IB Action
        
        private func newMailAction(){
                self.curSelectedMail = nil
                DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "ComposeNewMailSEG", sender: self)
                }
        }
        
        @IBAction func CreateNewMail(_ sender: UIButton) {
                
                if StampWallet.CurSWallet.isEmpty() || StampWallet.CurSWallet.isOpen(){
                        self.newMailAction()
                        return
                }
                self.ShowOneInput(title: "Stamp Wallet", placeHolder: "Stamp Wallet Password", type: .default){
                        (password, isOK) in
                        guard let pwd = password, isOK else{
                                return
                        }
                        
                        if !StampWallet.CurSWallet.openWallet(auth: pwd){
                                self.ShowTips(msg: "Open Stamp Wallet Failed")
                                return
                        }
                        self.newMailAction()
                }
        }
        
        func refreshMailList(){ mailOpQueue.async {
                let _ = MailManager.PopInboxMail(olderThanSince: false,
                                                         cb: self.mailHelper)
                self.reloadTableData()
                
        }}
        @objc func BPopMailFromServer(_ sender: UIRefreshControl) {
                
                guard let account = AccountManager.currentAccount else {
                        return
                }
                
                guard self.curViewType == .Inbox else{
                        self.reloadTableData()
                        return
                }
                
                guard account.isOpen() else {
                        self.OpenWallet(title: "Mail Account".locStr, placeHolder: "Mail Password".locStr) {
                                actTyp in
                                
                                guard actTyp == .Success else{
                                        DispatchQueue.main.async {
                                                self.refreshControl.endRefreshing()
                                        }
                                        return
                                }
                                self.refreshMailList()
                        }
                        return
                }
                refreshMailList()
        }
        
        @IBAction func ShowMenu(_ sender: UIBarButtonItem) {
                delegate?.toggleLeftPanel()
        }
        
        private func clearAllTrashs(){
                self.showConfirm(msg: "Confirm to Clear?".locStr, yesHandler:({
                        MailManager.ClearTrashes()
                        DispatchQueue.main.async {
                                self.envelopTableView.reloadData()
                        }
                }))
        }
        //MARK: - Internal funcs
        @objc internal  func MoreAction(_ sender: UIBarButtonItem) {
                
                if curViewType == .Draft || curViewType == .Recycle{
                        let alertController = UIAlertController(title: nil,
                                                                message: nil,
                                                                preferredStyle: .actionSheet)
                        
                        let cancel = UIAlertAction(title: "Cancel".locStr, style: .cancel)
                        let delete = UIAlertAction(title: "Clear All".locStr, style: .destructive) { _ in
                                if self.curViewType == .Draft{
                                        MailManager.ClearDrafts()
                                        DispatchQueue.main.async {
                                                self.envelopTableView.reloadData()
                                        }
                                }else{
                                        self.clearAllTrashs()
                                }
                        }
                        
                        [delete, cancel].forEach(alertController.addAction)
                        alertController.popoverPresentationController?.barButtonItem = sender
                        alertController.popoverPresentationController?.sourceRect = self.view.frame
                        present(alertController, animated: true, completion: nil)
                }
        }
        
        @objc internal  func UnreadMail(_ sender: UIBarButtonItem) {
        }
        
        func decryptCurrentMailList(){DispatchQueue.main.async {
                if self.isDecrypted == false{
                        self.decrypteButtonItem.image = UIImage.init(named: "open-block-icon")
                        self.isDecrypted = true
                }else{
                        self.isDecrypted = false
                        self.decrypteButtonItem.image = UIImage.init(named: "block-icon")
                }

                MailManager.EnDecryptMails(decrypt: self.isDecrypted, callback: nil)
                self.envelopTableView.reloadData()
        }}
        
        @objc internal  func DecryptMailList(_ sender: UIBarButtonItem) {
                guard let account = AccountManager.currentAccount else {
                        return
                }
                
                guard account.isOpen() else {
                        self.OpenWallet(title: "Mail Account".locStr, placeHolder: "Password".locStr) { actType in
                                if actType == .Success {self.decryptCurrentMailList()}
                        }
                        return
                }
                
                self.decryptCurrentMailList()
        }
        
        
        @objc internal  func foldMail(_ sender: UIBarButtonItem) {
        }
        
        
        @objc internal  func LabelMail(_ sender: UIBarButtonItem) {
        }
        
        
        @objc internal  func RemoveMail(_ sender: UIBarButtonItem) {
        }
        
        
        @objc internal  func SearchMailAction(_ sender: UIBarButtonItem) {
        }
        
        @objc internal func NewMailAction(_ sender: UIBarButtonItem) {
                self.curSelectedMail = nil
                self.performSegue(withIdentifier: "ComposeNewMailSEG", sender: self)
        }
        
        func configureNavigationBar() {
                self.navigationController?.navigationBar.barTintColor = UIColor.white// UIColor(RRGGBB: UInt(0x505061))
                self.setNeedsStatusBarAppearanceUpdate()
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
                if segue.identifier == "ComposeNewMailSEG"{
                        let navVC : UINavigationController = segue.destination as! UINavigationController
                        let vc = navVC.viewControllers.first as! ComposeMailViewController
                        vc.delegate = self
                        if curViewType == .Draft{
                                vc.currentMail = curSelectedMail
                        }
                        vc.actionType = .New
                }
                
                if segue.identifier == "ShowMailContentSEG"{
                        let vc = segue.destination as! EmailDetailViewController
                        vc.SelMail = curSelectedMail
                        vc.curType = curViewType
                        vc.delegate = self
                        vc.mailIdx = self.curSelectedMailIdx
               }
        }
}

extension InboxViewController: UITableViewDelegate, UITableViewDataSource{
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                self.curSelectedMailIdx = indexPath.row
                self.curSelectedMail = MailManager.CurrentMailList[indexPath.row]
                switch curViewType {
                case .Draft:
                        self.performSegue(withIdentifier: "ComposeNewMailSEG", sender: self)
                        
                case .Sent, .Recycle, .Inbox:
                        self.performSegue(withIdentifier: "ShowMailContentSEG", sender: self)
                        if curSelectedMail?.isUnread == true{
                                curSelectedMail?.isUnread = false
                                let _ = curSelectedMail?.store()
                                MailManager.reloadCounter(typ: curViewType)
                                tableView.reloadData()
                        }
                default:
                        return
                }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return MailManager.CurrentMailList.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MailboxTableViewCellID", for: indexPath) as! MailboxTableViewCell
                let mail = MailManager.CurrentMailList[indexPath.row]
                
                cell.fullfillData(data:mail)
                
                if indexPath.row == MailManager.CurrentMailList.count - 1 {
                        let has_more = MailManager.LoadCachedMail(type: curViewType, isDecryptMode: self.isDecrypted, since: mail.timeSince1970)
                        if has_more{
                                tableView.reloadData()
                        }
                }
                
                return cell
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
                guard editingStyle == .delete else{return}
                
                tableView.beginUpdates()
                if curViewType == .Recycle || curViewType == .Draft{
                        MailManager.removeAtIndex(indexPath.row)
                }else{
                        MailManager.trashAtIndex(indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
        }
        
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
                if curViewType == .Recycle || curViewType == .Draft{
                        return "Delete".locStr
                }
                return "Trash".locStr
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
                return true
        }
}

extension InboxViewController: ComposerSendMailDelegate{
        
        func reloadTableData(){
               let _ = MailManager.LoadCachedMail(type: self.curViewType, isDecryptMode: self.isDecrypted)
                MailManager.reloadCounter(typ: self.curViewType)
                DispatchQueue.main.async {
                        self.envelopTableView.reloadData()
                        self.refreshControl.endRefreshing()
                }
        }
        
        func sendMail(mail: EnvelopeEntity) {mailOpQueue.async {
                
                guard mail.encodeEnvlopeByPin() == true else{
                        self.ShowTips(msg: "Failed to encrypt mail data".locStr)
                        return
                }
                guard let str = mail.ToJsonString() else{ return }
                if !BmailLibSendMailJson(str, mail.pinCode, self.mailHelper){
                        self.newDraft(draft: mail)
                        return
                }
                
                mail.isSent = true
                mail.isDraft = false
                
                let _ = mail.store()
                if self.curViewType == .Sent || self.curViewType == .Draft{
                        self.reloadTableData()
                }}
        }
        
        func newDraft(draft: EnvelopeEntity) {mailOpQueue.async {
                draft.isSent = false
                draft.isDraft = true
                if draft.store(){
                        MailManager.reloadCounter(typ: .Draft)
                }
                
                if self.curViewType == .Draft{
                        self.reloadTableData()
                }}
        }
        
        func deleteDraft(draftId: String) {
                MailManager.removeFromLocDB(Eid:draftId)
                MailManager.reloadCounter(typ: .Draft)
                
                if curViewType == .Draft{
                        self.reloadTableData()
                }
        }
}

extension InboxViewController: CenterViewController{
        func setDelegate(delegate: CenterViewControllerDelegate) {
                self.delegate = delegate
        }
        
        public  func changeContext(viewType:MailActionType) {
                self.curViewType = viewType
                
                self.navigationController?.title = curViewType.Name
                self.title = curViewType.Name
                self.reloadTableData()
                var rightButtons:[UIBarButtonItem] = []
                switch viewType {
                case .Inbox:
                        rightButtons = [decrypteButtonItem]
                case .Draft:
                        rightButtons = [moreBarButtonItem]
                case .Sent:
                        rightButtons = [decrypteButtonItem]
                case .StarMail:
                        rightButtons = [searchBarButtonItem]
                case .Archieved:
                        rightButtons = [searchBarButtonItem]
                case .Spam:
                        rightButtons = [moreBarButtonItem]
                case .Recycle:
                        rightButtons = [moreBarButtonItem, decrypteButtonItem]
                case .AllMail:
                        rightButtons = []
                default:
                        return
                }
                
                self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        }
}

extension InboxViewController: EmailDetailDelegate{
        func reloadMailList() {
                DispatchQueue.main.async {
                        self.envelopTableView.reloadData()
                }
        }
}

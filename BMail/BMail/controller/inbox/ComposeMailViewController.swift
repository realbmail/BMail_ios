//
//  ComposeMailViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/4.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import CLTokenInputView
import CICropPicker
import Photos
import TLPhotoPicker
import ContactsUI


protocol ComposerSendMailDelegate: class {
        func sendMail(mail: EnvelopeEntity, stamp:Stamp?)
        func newDraft(draft: EnvelopeEntity)
        func deleteDraft(draftId: String)
}

class ComposeMailViewController: UIViewController {
        
        enum ActionType{
                case New
                case Forward
                case Reply
                case ReplyAll
        }
        
        let DEFAULT_ATTACHMENTS_HEIGHT = 303
        let MAX_ROWS_BEFORE_CALC_HEIGHT = 3
        let ATTACHMENT_ROW_HEIGHT = 65
        let MARGIN_TOP = 5
        let CONTACT_FIELDS_HEIGHT = 90
        let ENTER_LINE_HEIGHT : CGFloat = 28.0
        let TOOLBAR_MARGIN_HEIGHT = 25
        let COMPOSER_MIN_HEIGHT = 150
        let PASSWORD_POPUP_HEIGHT = 295
        let ATTACHMENT_BUTTON_HEIGHT = 32.0
        
        @IBOutlet weak var ToField: CLTokenInputView!
        @IBOutlet weak var FromSelectButon: UIButton!
        @IBOutlet weak var FromLabel: UILabel!
        @IBOutlet weak var ToFieldButton: UIButton!
        @IBOutlet weak var CCField: CLTokenInputView!
        @IBOutlet weak var BCCField: CLTokenInputView!
        @IBOutlet weak var BottomSeparator: UIView!
        @IBOutlet weak var SubjectField: UITextField!
        @IBOutlet weak var EditorView: RichEditorView!
        @IBOutlet weak var ToolBarView: UIView!
        @IBOutlet weak var AttachmentButtonContainerView: UIView!
        @IBOutlet weak var BlackGroundView: UIView!
        @IBOutlet weak var scrollView: UIScrollView!
        @IBOutlet weak var editorHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var bccHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var ccHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var contactTableView: UITableView!
        @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var contactTableViewTopConstraint: NSLayoutConstraint!
        @IBOutlet weak var toHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var attachmentContainerBottomConstraint: NSLayoutConstraint!
        @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var attachmentTableHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var sendMailBarItem: UIBarButtonItem!
        @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
        
        var composerKeyboardOffset: CGFloat = 0.0
        var composerEditorHeight: CGFloat = 0.0
        var expandedBbcSpacing: CGFloat = 45
        var expandedCcSpacing: CGFloat = 45
        var attachmentOptionsHeight: CGFloat = 110
        let rowHeight:CGFloat = 65.0
        var isEdited:Bool = false
        var toolbarBottomConstraintInitialValue: CGFloat?
        var toolbarHeightConstraintInitialValue: CGFloat? = 0
        let imagePicker = CICropPicker()
        var inputFailed: [CLTokenInputView: Bool] = [:]
        var dismissTapGestureRecognizer: UITapGestureRecognizer!
        var selectedTokenInputView:CLTokenInputView?
        var CryptStatus = false
        var activeAccount = AccountManager.currentAccount!
        var delegate:ComposerSendMailDelegate?
        var currentMail:EnvelopeEntity?
        var actionType:ActionType?
        
        override func viewDidLoad() {
                
                super.viewDidLoad()
                
                setFromField()
                
                self.ToField.fieldName = "TO".locStr
                self.ToField.delegate = self
                
                self.EditorView.placeholder = "MESSAGE".locStr
                self.EditorView.delegate = self
                self.SubjectField.delegate = self
                self.SubjectField.addInputAccessoryView(title: "Done".locStr, flag:1, target: self, selector: #selector(onDonePress(_:)))
                
                let sysColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
                let toFieldButton = UIButton(type: .custom)
                toFieldButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
                toFieldButton.setTitle("+", for: .normal)
                toFieldButton.setTitleColor(sysColor, for: .normal)
                toFieldButton.addTarget(self, action: #selector(didPressAccessoryView(_:)), for: .touchUpInside)
                self.ToField.accessoryView = toFieldButton
                self.ToField.accessoryView?.isHidden = true
                
                self.BCCField.fieldName = "BCC".locStr
                self.BCCField.delegate = self
                
                let bccFieldButton = UIButton(type: .custom)
                bccFieldButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
                bccFieldButton.setTitle(("+"), for: .normal)
                bccFieldButton.setTitleColor(sysColor, for: .normal)
                bccFieldButton.addTarget(self, action: #selector(didPressAccessoryView(_:)), for: .touchUpInside)
                self.BCCField.accessoryView = bccFieldButton
                self.BCCField.accessoryView?.isHidden = true
                
                self.CCField.fieldName = "CC".locStr
                self.CCField.delegate = self
                
                let ccFieldButton = UIButton(type: .custom)
                ccFieldButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
                ccFieldButton.setTitle("+", for: .normal)
                ccFieldButton.setTitleColor(sysColor, for: .normal)
                ccFieldButton.addTarget(self, action: #selector(didPressAccessoryView(_:)), for: .touchUpInside)
                self.CCField.accessoryView = ccFieldButton
                self.CCField.accessoryView?.isHidden = true
                
                self.contactTableView.isHidden = true
                
                self.EditorView.isScrollEnabled = false
                self.editorHeightConstraint.constant = 150
                self.attachmentContainerBottomConstraint.constant = 50
                
                self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
                self.toolbarHeightConstraintInitialValue = toolbarHeightConstraint.constant
                
                //3
                self.enableKeyboardHideOnTap()
                
                self.imagePicker.delegate = self
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(hideBlackBackground(_:)))
                self.BlackGroundView.addGestureRecognizer(tap)
                BmailContact.FileterBy(key: "")
                self.tableView.separatorStyle = .none
                self.tableView.tableFooterView = UIView()
                self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didPressAttachment(_:)))
                self.AttachmentButtonContainerView.addGestureRecognizer(tapGesture)
                AttachmentButtonContainerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
                AttachmentButtonContainerView.layer.borderColor = UIColor.white.cgColor
                 let rightButtons = [self.sendMailBarItem!]//self.moreBarButtonItem!,
                self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
                
                if currentMail == nil{
                        currentMail = EnvelopeEntity()
                        return
                }
                
                populateDraft()
        }
        
        private func populateDraft(){
                
                switch self.actionType {
                case .New:
                        self.EditorView.html = currentMail!.rawBody ?? ""
                        self.SubjectField.text = currentMail!.rawSubject
                        
                        for (_, r) in currentMail!.Tos{
                                addToken(r, to: self.ToField)
                        }
                        for (_, r) in currentMail!.CCs{
                                addToken(r, to: self.CCField)
                        }
                        for (_, r) in currentMail!.BCCs{
                                addToken(r, to: self.BCCField)
                        }
                        return
                        
                 case .Forward:
                        self.SubjectField.text = "Fw: \(currentMail?.rawSubject ?? "")"
                        self.EditorView.html = "<br/><hr/>\(currentMail!.fromName!): \(currentMail?.rawBody ?? "")"
                        currentMail = EnvelopeEntity()
                        break
                        
                case .Reply:
                        self.SubjectField.text  = "Re: \(currentMail?.rawSubject ?? "")"
                        self.EditorView.html    = "<br/><hr/>\(currentMail!.fromName!): \(currentMail?.rawBody ?? "")"
                        let to = "\(currentMail!.fromName!),"
                        currentMail = EnvelopeEntity(SID: currentMail?.eid)
                        self.ToField.text = to
                        self.tokenInputView(self.ToField, didChangeText: to)
                        break
                        
                case .ReplyAll:
                        self.SubjectField.text  = "Re: \(currentMail?.rawSubject ?? "")"
                        self.EditorView.html    = "<br/><hr>\(currentMail!.fromName!): \(currentMail?.rawBody ?? "")"
                       
                        let self_acc = AccountManager.currentAccount?.MailName()
                        var tos:String = "\(currentMail!.fromName!),"
                        for (_, r) in currentMail!.Tos{
                                if self_acc == r.mailName{
                                        continue
                                }
                                tos.append(r.mailName)
                                tos.append(",")
                        }
                        
                        var rcc:String = ""
                        for (_, r) in currentMail!.CCs{
                                if self_acc == r.mailName{
                                        continue
                                }
                                rcc.append(r.mailName)
                                rcc.append(",")
                        }
                        currentMail = EnvelopeEntity(SID: currentMail?.eid)
                        self.ToField.text = tos
                        self.tokenInputView(self.ToField, didChangeText: tos)
                        self.CCField.text = rcc
                        self.tokenInputView(self.CCField, didChangeText: rcc)
                        break
                default:
                        break
                }
        }
        
        private func BarItem(image: UIImage?, action: Selector? ) -> UIBarButtonItem {
                return  UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: action)
        }
        
        override func viewDidAppear(_ animated: Bool) {
        }
        
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
        }
        
        func remove(_ attachment:File){
                
                //            guard let index = fileManager.registeredFiles.firstIndex(where: { (attach) -> Bool in
                //                return attach == attachment
                //            }) else {
                //                //if not found, do nothing
                //                return
                //            }
                //            self.removeAttachment(at: IndexPath(row: index, section: 0))
        }
        
        func removeAttachment(at indexPath:IndexPath){
                //            _ = fileManager.registeredFiles.remove(at: indexPath.row)
                self.toggleAttachmentTable()
                self.tableView.reloadData()
        }
        
        func composeMail(){
                self.resignKeyboard()
                
                currentMail!.timeSince1970 = Int64(Date.init().timeIntervalSince1970 * 1000)
                currentMail!.rawBody = self.EditorView.contentHTML
                currentMail!.rawSubject = self.SubjectField.text ?? ""
                currentMail!.fromAddress = activeAccount.Address()
                currentMail!.fromName = activeAccount.MailName()
        }
        
        func getEmailFromToken(_ token: CLToken) -> String {
                var email = ""
                if let emailTemp = token.context as? NSString {
                        email = String(emailTemp)
                } else {
                        email = token.displayText
                }
                return email
        }
        
        func toggleInteraction(_ flag:Bool){
                self.view.isUserInteractionEnabled = flag
                self.navigationController?.navigationBar.layer.zPosition = flag ? 0 : -1
                self.BlackGroundView.isUserInteractionEnabled = flag
                self.BlackGroundView.alpha = flag ? 0 : 0.5
        }
        
        //MARK: - Button Actions
        @IBAction func onDidEndOnExit(_ sender: Any) {
                self.onDonePress(sender)
        }
        
        @IBAction func ChangeToAccount(_ sender: UIButton) {
                let needsCollapsing = self.bccHeightConstraint.constant != 0
                self.collapseCC(needsCollapsing)
        }
        
        @IBAction func ChangeFromAccount(_ sender: UIButton) {
        }
        
        @IBAction func DidPressAttachmentLibrary(_ sender: Any) {
                PHPhotoLibrary.requestAuthorization({ (status) in
                        DispatchQueue.main.async {
                                switch status {
                                case .authorized:
                                        let picker = TLPhotosPickerViewController()
                                        picker.delegate = self
                                        var configure = TLPhotosPickerConfigure()
                                        configure.allowedVideoRecording = false
                                        picker.configure = configure
                                        self.present(picker, animated: true, completion: nil)
                                        let isSystemDarkMode = IsSystemDarlkModeEnabled(controller: self)
                                        picker.doneButton.tintColor = isSystemDarkMode ? .white : .black
                                        picker.cancelButton.tintColor = isSystemDarkMode ? .white : .black
                                        break
                                default:
                                        self.ShowTips(msg: "No rights to access".locStr)
                                        break
                                }
                        }
                })
        }
        
        @IBAction func DidPressAttachmentCamera(_ sender: Any) {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                        DispatchQueue.main.async {
                                if !granted {
                                        self.ShowTips(msg: "No rights to access".locStr)
                                        return
                                }
                                self.imagePicker.presentCameraPicker(from: self)
                        }
                })
        }
        
        @IBAction func DidPressAttachmentDocuments(_ sender: Any) {
                let providerList = UIDocumentPickerViewController(documentTypes: ["public.content", "public.data"], in: .import)
                providerList.delegate = self;
                
                providerList.popoverPresentationController?.sourceView = self.view
                providerList.popoverPresentationController?.sourceRect = CGRect(x: Double(self.view.bounds.size.width / 2.0), y: Double(self.view.bounds.size.height-45), width: 1.0, height: 1.0)
                let isSystemDarkMode = IsSystemDarlkModeEnabled(controller: self)
                providerList.popoverPresentationController?.barButtonItem?.tintColor = isSystemDarkMode ? .white : .black
                providerList.modalPresentationStyle = .fullScreen
                self.present(providerList, animated: true, completion: nil)
        }
        
        @IBAction func didPressAttachment(_ sender: UIButton) {
                self.showAttachmentDrawer(true)
        }
        
        @IBAction func CloseMailEdit(_ sender: UIBarButtonItem) {
                if !self.isEdited {
                        self.dismiss(animated: true, completion: nil)
                        return
                }
                
                let alertController = UIAlertController(title: "Confirm".locStr,
                                                        message: nil,
                                                        preferredStyle: .actionSheet)
                let save = UIAlertAction(title: "Save Draft".locStr,
                                         style: .default) { _ in
                                                self.composeMail()
                                                self.delegate?.newDraft(draft: self.currentMail!)
                                                self.dismiss(animated: true, completion: nil)
                }
                let cancel = UIAlertAction(title: "Cancel".locStr, style: .cancel)
                let delete = UIAlertAction(title: "Drop Draft".locStr, style: .destructive) { _ in
                        if let eid = self.currentMail?.eid {
                                self.delegate?.deleteDraft(draftId: eid)
                        }
                        self.dismiss(animated: true, completion: nil)
                }
                
                // for UITests
                save.accessibilityLabel = "saveDraftButton"
                cancel.accessibilityLabel = "cancelDraftButton"
                delete.accessibilityLabel = "deleteDraftButton"
                
                [save, delete, cancel].forEach(alertController.addAction)
                alertController.popoverPresentationController?.barButtonItem = sender
                alertController.popoverPresentationController?.sourceRect = self.view.frame
                present(alertController, animated: true, completion: nil)
        }
        
        private func checkRcptFields() -> Bool{
                if self.inputFailed[self.ToField] == true{
                        self.ToField.beginEditing()
                        return false
                }
                if self.inputFailed[self.CCField] == true{
                        self.collapseCC(false)
                        self.CCField.beginEditing()
                        return false
                }
                if self.inputFailed[self.BCCField] == true{
                        self.collapseCC(false)
                        self.BCCField.beginEditing()
                        return false
                }
                return true
        }
        
        private func sendAction(){
                
                DispatchQueue.main.async {
                        self.composeMail()
                        self.currentMail?.MergerRcpts()
                        if self.currentMail?.rcpts.count == 0{
                                self.ShowTips(msg: "No valid receipt".locStr)
                                return
                        }
                        if self.checkRcptFields() == false{
                                self.ShowTips(msg: "Invalid mail adress".locStr)
                                return
                        }
                        
                        self.resignKeyboard()
                        self.toggleInteraction(false)
                        self.dismiss(animated: true){
                                self.delegate?.sendMail(mail: self.currentMail!, stamp: nil)
                        }
                }
        }
        
        @IBAction func DidSendBmail(_ sender: UIBarButtonItem) {
                
                guard activeAccount.isOpen() else {
                        self.OpenWallet(title: "Confirm".locStr, placeHolder: "Mail Author".locStr) { actType in
                                if actType == .Success {self.sendAction()}
                        }
                        return
                }
                
                sendAction()
        }
        
        //MARK: - local logic
        private func setFromField(){
                let attributedFrom = NSMutableAttributedString(string: "FROM:".locStr,
                                                               attributes: [.font: UIFont.boldSystemFont(ofSize: 15)])
                let attributedEmail = NSAttributedString(string: activeAccount.MailName()!,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 15)])
                attributedFrom.append(attributedEmail)
                FromLabel.attributedText = attributedFrom
                FromSelectButon.isHidden = AccountManager.mailAccounts.count <= 1
        }
        
        @objc func onDonePress(_ sender: Any){
                let item = sender as? UIBarItem
                if item != nil && item!.tag == 1{
                        let _ = EditorView.becomeFirstResponder()
                        return
                }
                switch(sender as? UIView){
                case ToField:
                        SubjectField.becomeFirstResponder()
                case SubjectField:
                        let _ = EditorView.becomeFirstResponder()
                default:
                        break
                }
        }
        
        @objc func didPressAccessoryView(_ sender: UIButton) {
                let tokenInputView = sender.superview as! CLTokenInputView
                
                tokenInputView.beginEditing()
        }
        
        func collapseCC(_ shouldCollapse: Bool){
                //do not collapse if already collapsed
                if shouldCollapse && self.bccHeightConstraint.constant == 0 {
                        return
                }
                //do not expand if already expanded
                if !shouldCollapse && self.bccHeightConstraint.constant > 0 {
                        return
                }
                
                if (shouldCollapse) {
                        expandedCcSpacing = self.ccHeightConstraint.constant
                        expandedBbcSpacing = self.bccHeightConstraint.constant
                }
                
                self.ToFieldButton.setImage(shouldCollapse ? UIImage(named: "icon-down") : UIImage(named: "icon-up"), for: .normal)
                self.bccHeightConstraint.constant = shouldCollapse ? 0 : self.expandedBbcSpacing
                self.ccHeightConstraint.constant = shouldCollapse ? 0 : self.expandedCcSpacing
                
                UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                })
        }
        
        @objc func hideBlackBackground(_ flag:Bool = false){
                
                self.showAttachmentDrawer(false)
                self.resignKeyboard()
                self.navigationController?.navigationBar.layer.zPosition = flag ? -1 : 0
                UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                        self.BlackGroundView.alpha = 0
                }
        }
        
        func showAttachmentDrawer(_ flag:Bool = false){
                self.resignKeyboard()
                self.navigationController?.navigationBar.layer.zPosition = flag ? -1 : 0
                
                self.attachmentContainerBottomConstraint.constant = CGFloat(flag ? -attachmentOptionsHeight : 50)
                UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                        self.BlackGroundView.alpha = flag ? 0.5 : 0
                }
        }
        
        func resignKeyboard() {
                self.ToField.endEditing()
                self.CCField.endEditing()
                self.BCCField.endEditing()
                self.SubjectField.resignFirstResponder()
                self.EditorView.webView.endEditing(true)
        }
}

//MARK: - TextField Delegate
extension ComposeMailViewController: UITextFieldDelegate {
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                if !self.isEdited && !(textField.text?.isEmpty)!{
                        self.isEdited = true
                }
                
                return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
                self.collapseCC(true)
        }
}

//MARK: - RichEditorDelegate Delegate
extension ComposeMailViewController: RichEditorDelegate{
        
        func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
                let cgheight = CGFloat(height)
                let diff = cgheight - composerEditorHeight
                let offset = self.scrollView.contentOffset
                
                let calcHeight = self.AttachmentButtonContainerView.layer.borderWidth + CGFloat(ATTACHMENT_BUTTON_HEIGHT)
                if CGFloat(height + CONTACT_FIELDS_HEIGHT + TOOLBAR_MARGIN_HEIGHT) + calcHeight > self.ToolBarView.frame.origin.y {
                        var newOffset = CGPoint(x: offset.x, y: offset.y + ENTER_LINE_HEIGHT)
                        if diff == -ENTER_LINE_HEIGHT  {
                                newOffset = CGPoint(x: offset.x, y: offset.y - ENTER_LINE_HEIGHT)
                        }
                        
                        if self.isEdited && !editor.webView.isLoading {
                                self.scrollView.setContentOffset(newOffset, animated: true)
                        }
                }
                
                guard height > COMPOSER_MIN_HEIGHT else {
                        return
                }
                
                composerEditorHeight = cgheight
                self.editorHeightConstraint.constant = cgheight + self.AttachmentButtonContainerView.layer.borderWidth + CGFloat(ATTACHMENT_BUTTON_HEIGHT) + composerKeyboardOffset
        }
        
        func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
                guard !self.isEdited else {
                        return
                }
                if(!content.isEmpty){
                        self.isEdited = true
                }
        }
        
        func richEditorDidLoad(_ editor: RichEditorView) {
                
                //            editor.replace(font: "NunitoSans-Regular", css: "editor-style")
                //            let hasInitialContacts = composerData.initToContacts.count > 0 || composerData.initCcContacts.count > 0
                //            if(hasInitialContacts){
                //                self.setupInitContacts()
                //            }
                //            if(!hasInitialContacts){
                //                ToField.beginEditing()
                //            } else if(!composerData.initSubject.isEmpty){
                //                EditorView.focus(at: CGPoint(x: 0.0, y: 0.0))
                //            } else {
                //                SubjectField.becomeFirstResponder()
                //            }
                EditorView.setEditorFontColor(UIColor(red: 55/255, green: 58/255, blue: 69/255, alpha: 1))
                //            EditorView.setEditorBackgroundColor(UIColor.white)
                //
        }
        
        func richEditorTookFocus(_ editor: RichEditorView) {
                self.collapseCC(true)
                //            let defaults = CriptextDefaults()
                //            if !defaults.guideAttachments {
                //                let presentationContext = PresentationContext.viewController(self)
                //                self.coachMarksController.start(in: presentationContext)
                //                defaults.guideAttachments = true
                //            }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        guard let focusPoint = (self.EditorView as? RichEditorWrapperView)?.lastFocus else {
                                return
                        }
                        self.EditorView.focus(at: focusPoint)
                }
        }
        
        func richEditorLostFocus(_ editor: RichEditorView) {
                (EditorView as? RichEditorWrapperView)?.lastFocus = nil
        }
}


//MARK: - Token Input Delegate
extension ComposeMailViewController: CLTokenInputViewDelegate {
        
        func tokenInputView(_ view: CLTokenInputView, didChangeText text: String?) {
                if !self.isEdited {
                        self.isEdited = true
                }
                
                let characterSet = CharacterSet(charactersIn: " ,")
                view.text = view.text?.trimmingCharacters(in: characterSet)
                
                if let input = view.text, input.count > 0 && (text?.last == " " || text?.last == ",") {
                        handleRecipientsInput(input: input, tokenView: view)
                        return
                }
                
                BmailContact.FileterBy(key: view.text)
                let noContact = BmailContact.FilteredData.count == 0 || view.text?.isEmpty ?? true

//                ToolBarView.isHidden = !noContact
                self.contactTableView.isHidden = noContact
                self.toolbarHeightConstraint.constant = noContact ? self.toolbarHeightConstraintInitialValue! : 0
                self.contactTableView.reloadData()
                self.view.layoutIfNeeded()
        }
        
        func handleRecipientsInput(input: String, tokenView: CLTokenInputView) {
                
                guard input.count > 0 else {
                    inputFailed[tokenView] = false
                    return
                }
                
                let inputText = input.replacingOccurrences(of: " ", with: ",")
                let mailNames = inputText.split(separator: ",").map( {$0.description} )
                var invalid_mail = ""
                var no_blockchain_info = ""
                
                for dn in mailNames {
                        print("-----dn=[\(dn)]=>")
                        guard ValidateEmail(dn) else{
                                invalid_mail += ",\(dn)"
                                continue
                        }
                        
                        guard let contact = BmailContact.QueryAddress(mailName: dn) else{
                                no_blockchain_info += ",\(dn)"
                                continue
                        }

                        let rcpt = Receipt.init(typ: RcptType(rawValue: Int8(tokenView.tag))!, contact: contact)
                        addToken(rcpt, to: tokenView)
                }
                
                if invalid_mail.count > 0 {
                        self.ShowTips(msg: "Invalid BMail".locStr + "[\(invalid_mail)]")
                        inputFailed[tokenView] = true
                }
                
                if no_blockchain_info.count > 0{
                        self.ShowTips(msg: "No Blockchain record for:".locStr + "[\(no_blockchain_info)]")
                        inputFailed[tokenView] = true
                }
        }
        
        func tokenInputViewDidBeginEditing(_ view: CLTokenInputView) {
                
                if view == self.ToField {
                        self.contactTableViewTopConstraint.constant = 1
                }
                
                if view == self.CCField {
                        self.contactTableViewTopConstraint.constant = view.bounds.height
                }
                
                if view == self.BCCField {
                        self.contactTableViewTopConstraint.constant = self.CCField.bounds.height + self.BCCField.bounds.height
                }
        }
        
        func tokenInputViewDidEndEditing(_ view: CLTokenInputView) {
                self.contactTableView.isHidden = true
                guard let text = view.text else {
                        return
                }
                
                handleRecipientsInput(input: text, tokenView: view)
                
        }
        
        func tokenInputView(_ view: CLTokenInputView, didRemove token: CLToken) {
                guard let r = token.context as? Receipt else {
                        return
                }
                guard let t =  RcptType.init(rawValue: Int8(view.tag)) else {
                        return
                }
                currentMail?.RemoveRcpt(typ: t, name: r.mailName)
                print("======>token removed--\(token.displayText) ==\(r.mailName)->")
        }
        
        func tokenInputView(_ view: CLTokenInputView, didChangeHeightTo height: CGFloat) {
                if view == self.ToField {
                        self.toHeightConstraint.constant = height
                        if self.ToField.isEditing {
                                self.contactTableViewTopConstraint.constant = 1
                        }
                } else if view == self.CCField {
                        self.ccHeightConstraint.constant = height
                        
                        if self.CCField.isEditing {
                                self.contactTableViewTopConstraint.constant = height
                        }
                } else if view == self.BCCField {
                        self.bccHeightConstraint.constant = height
                        
                        if self.BCCField.isEditing {
                                self.contactTableViewTopConstraint.constant = self.CCField.bounds.height + height
                        }
                }
        }
        
        func tokenInputViewShouldReturn(_ view: CLTokenInputView) -> Bool {
                switch(view){
                case ToField:
                        if(self.bccHeightConstraint.constant == 0){
                                SubjectField.becomeFirstResponder()
                                break
                        }
                        CCField.beginEditing()
                case CCField:
                        BCCField.beginEditing()
                default:
                        SubjectField.becomeFirstResponder()
                }
                return false
        }
        
        func addToken(_ rcpt:Receipt, to view:CLTokenInputView){
                
                var display = ""
                if let name = rcpt.displayName, name.count > 0{
                        display = name
                }else{
                        display = rcpt.mailName
                }
                
                for t in view.allTokens{
                        if t.displayText != display{
                                continue
                        }
                        view.text = ""
                        self.tokenInputView(view, didChangeText: "")
                        return
                }
                
                let textColor = UIColor(red: CGFloat(8)/255, green: CGFloat(10)/255, blue:  CGFloat(50)/255, alpha: 1)
                let bgColor = UIColor(red: CGFloat(242)/255, green: CGFloat(133)/255, blue:  CGFloat(82)/255, alpha: 0.3)
                let token = CLToken(displayText: display, context: rcpt)
                view.add(token, highlight: textColor, background: bgColor)
                currentMail?.AddRcpt(typ: rcpt.type, r: rcpt)
        }
}

//MARK: - Keyboard handler
extension ComposeMailViewController{
        // 3
        // Add a gesture on the view controller to close keyboard when tapped
        func enableKeyboardHideOnTap(){
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil) // See 4.1
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil) //See 4.2
        }
        
        //3.1
        @objc func hideKeyboard() {
                composerKeyboardOffset = 0.0
                self.editorHeightConstraint.constant = composerEditorHeight
                self.view.endEditing(true)
        }
        
        //4.1
        @objc func keyboardWillShow(notification: NSNotification) {
                let info = notification.userInfo!
                let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                var marginBottom: CGFloat = 0.0
                if #available(iOS 11.0, *),
                        let window = UIApplication.shared.keyWindow {
                        marginBottom = window.safeAreaInsets.bottom
                }
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: duration) { () -> Void in
                        self.toolbarBottomConstraint.constant = keyboardFrame.size.height - marginBottom
                        self.view.layoutIfNeeded()
                }
                composerKeyboardOffset = keyboardFrame.size.height - marginBottom
                self.editorHeightConstraint.constant = composerEditorHeight + composerKeyboardOffset
        }
        
        //4.2
        @objc func keyboardWillHide(notification: NSNotification) {
                let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: duration) { () -> Void in
                        self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
                        self.view.layoutIfNeeded()
                        
                }
        }
        
        func toggleAttachmentTable(){
//               var height = DEFAULT_ATTACHMENTS_HEIGHT
//               if fileManager.registeredFiles.count > MAX_ROWS_BEFORE_CALC_HEIGHT {
//                   height = MARGIN_TOP + (fileManager.registeredFiles.count * ATTACHMENT_ROW_HEIGHT)
//               }
//
//               if fileManager.registeredFiles.isEmpty {
//                   height = 0
//               }
//
//               self.attachmentTableHeightConstraint.constant = CGFloat(height)
//               self.showAttachmentDrawer(false)
        }
}

//MARK: - Image Picker
extension ComposeMailViewController: CICropPickerDelegate {
        func imagePicker(_ imagePicker: UIImagePickerController!, pickedImage image: UIImage!) {
                
                //        let currentDate = Date().timeIntervalSince1970
                //        guard let data = image.jpegData(compressionQuality: 0.6) else {
                //            return
                //        }
                
                imagePicker.dismiss(animated: true){
                        //            let filename = "Criptext_Image_\(currentDate).png"
                        //            let mimeType = "image/png"
                        
                        //            let fileURL = CriptextFileManager.getURLForFile(name: filename)
                        //            try! data.write(to: fileURL)
                        
                        //            self.isEdited = true
                        //            self.fileManager.registerFile(filepath: fileURL.path, name: filename, mimeType: mimeType)
                        //            self.tableView.reloadData()
                        //            self.toggleAttachmentTable()
                }
        }
}

//MARK: - TableView Data Source
extension ComposeMailViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
                if tableView == self.contactTableView {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
                        let contact = BmailContact.FilteredData[indexPath.row]//[indexPath.row]
                        cell.FullFillData(contact)
                        return cell
                }
                
                //        let attachment = fileManager.registeredFiles[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentTableViewCell", for: indexPath) as! AttachmentTableViewCell
                
                //        cell.nameLabel.text = attachment.name
                //        cell.sizeLabel.text = attachment.prettyPrintSize()
                cell.lockImageView.image =  UIImage(named: "switch_locked_on")//Icon.lock.image
                
                cell.lockImageView.tintColor = UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)
                cell.lockImageView.image =  UIImage(named: "switch_locked_off")//Icon.lock_open.image
                
                //        cell.progressView.isHidden = attachment.requestStatus == .finish
                //        cell.successImageView.isHidden = attachment.requestStatus != .finish
                //
                //        cell.typeImageView.image = GetImageByFileType(attachment.mimeType)
                cell.delegate = self
                
                return cell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if tableView == self.contactTableView {
                    return BmailContact.FilteredData.count
                }
                return 0
        }
}

//MARK: - TableView Delegate
extension ComposeMailViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                if tableView == self.contactTableView {
                        return 60.0
                }
                return self.rowHeight
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
                tableView.deselectRow(at: indexPath, animated: true)
                if tableView == self.contactTableView {
                        let contact =  BmailContact.FilteredData[indexPath.row]
                        var focusInput:CLTokenInputView!
                        
                        if self.ToField.isEditing {
                                focusInput = self.ToField
                        }
                        
                        if self.CCField.isEditing {
                                focusInput = self.CCField
                        }
                        
                        if self.BCCField.isEditing {
                                focusInput = self.BCCField
                        }
                        let rcpt = Receipt.init(typ: RcptType(rawValue: Int8(focusInput.tag))!, contact: contact)
                        addToken(rcpt, to: focusInput)
                }
        }
}
extension ComposeMailViewController: AttachmentTableViewCellDelegate{
        func tableViewCellDidTapReadOnly(_ cell: AttachmentTableViewCell) {}
        
        func tableViewCellDidTapPassword(_ cell: AttachmentTableViewCell) {}
        
        func tableViewCellDidTapRemove(_ cell: AttachmentTableViewCell) {
                guard let indexPath = tableView.indexPath(for: cell) else {
                        return
                }
                //        fileManager.removeFile(filetoken: fileManager.registeredFiles[indexPath.row].token)
                tableView.deleteRows(at: [indexPath], with: .none)
        }
        
        func tableViewCellDidTap(_ cell: AttachmentTableViewCell) {
                //        guard let indexPath = tableView.indexPath(for: cell) else {
                //            return
                //        }
                //        fileManager.registerFile(file: fileManager.registeredFiles[indexPath.row], uploading: true)
        }
}


//MARK: - Document Handler Delegate
extension ComposeMailViewController: UIDocumentPickerDelegate {
        
        func documentMenu(didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
                //show document picker
                documentPicker.delegate = self;
                
                documentPicker.popoverPresentationController?.sourceView = self.view
                documentPicker.popoverPresentationController?.sourceRect = CGRect(x: Double(self.view.bounds.size.width / 2.0), y: Double(self.view.bounds.size.height-45), width: 1.0, height: 1.0)
                self.present(documentPicker, animated: true, completion: nil)
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
                
                //        let filename = url.lastPathComponent
                self.isEdited = true
                //        self.fileManager.registerFile(filepath: url.path, name: filename, mimeType: File.mimeTypeForPath(path: filename))
                self.tableView.reloadData()
                self.toggleAttachmentTable()
        }
}

//extension ComposeMailViewController: EmailSetPasswordDelegate {
//    func setPassword(active: Bool, password: String?) {
//        self.toggleInteraction(false)
//        sendMailInMainController(password: password)
//    }
//}


//MARK: - UIGestureRecognizer Delegate
extension ComposeMailViewController: UIGestureRecognizerDelegate {
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
                
                let touchPt = touch.location(in: self.view)
                
                guard let tappedView = self.view.hitTest(touchPt, with: nil) else {
                        return true
                }
                
                
                if gestureRecognizer == self.dismissTapGestureRecognizer && tappedView.isDescendant(of: self.contactTableView) && !self.contactTableView.isHidden {
                        return false
                }
                
                return true
        }
}


extension ComposeMailViewController: TLPhotosPickerViewControllerDelegate {
        func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
                for asset in withTLPHAssets {
                        switch(asset.type) {
                        case .photo, .livePhoto:
                                asset.tempCopyMediaFile(videoRequestOptions: nil, imageRequestOptions: nil, exportPreset: AVAssetExportPresetMediumQuality, convertLivePhotosToJPG: true, progressBlock: nil) { (url, mimeType) in
                                        DispatchQueue.main.async {
                                                let filename = url.absoluteString.split(separator: "/").last?.description ?? asset.originalFileName ?? "Unknown"
                                                self.handleAssetResult(name: filename, url: url, mimeType: mimeType)
                                        }
                                }
                        case .video:
                                asset.exportVideoFile(completionBlock: { (url, mimeType) in
                                        DispatchQueue.main.async {
                                                self.handleAssetResult(name: asset.originalFileName ?? "Unknown", url: url, mimeType: mimeType)
                                        }
                                })
                        }
                }
        }
        
        func handleAssetResult(name: String, url: URL, mimeType: String) {
//        guard self.fileManager.registerFile(filepath: url.path, name: name, mimeType: mimeType) else {
//            self.toggleAttachmentTable()
//            return
//        }
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                self.toggleAttachmentTable()
        }
}

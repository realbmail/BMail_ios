//
//  EmailDetailsTableViewCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/20.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

protocol MailCellActionDelegate {
        func tableViewReload(_ cell: EmailDetailsTableViewCell)
        func popoverContacts(_ mail: EnvelopeEntity, _ sender: UIView)
        func showOperationsForMail(_ cell: EmailDetailsTableViewCell, _ sender: UIView)
}

class EmailDetailsTableViewCell: UITableViewCell {
        
        enum IconType {
               case options
               case contacts
               case edit
           }
        
        let ATTATCHMENT_CELL_HEIGHT : CGFloat = 68.0
        let RECIPIENTS_MAX_WIDTH: CGFloat = 190.0
        let READ_STATUS_MARGIN: CGFloat = 5.0
        
        @IBOutlet weak var backGroundView: UIView!
        @IBOutlet weak var InfoViewContainer: UIView!
        @IBOutlet weak var MailBodyView: RichEditorView!
        @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var AttachmentTopMarginView: UIView!
        @IBOutlet weak var AttachmentTableView: UITableView!
        @IBOutlet weak var AttachmentTableHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var BottomMarginView: UIView!
        @IBOutlet weak var AvatarImageView: UIImageView!
        @IBOutlet weak var ContactsCollapseLabel: UILabel!
        @IBOutlet weak var previewLabel: UILabel!
        @IBOutlet weak var DateLabel: UILabel!
        @IBOutlet weak var MiniAttachmentImageView: UIImageView!
        @IBOutlet weak var DateWidthConstrant: NSLayoutConstraint!
        @IBOutlet weak var ContactsLabel: UILabel!
        @IBOutlet weak var ContactsLabelWidthConstrant: NSLayoutConstraint!
        @IBOutlet weak var MoreInfoContainerView: UIButton!
        @IBOutlet weak var DeleteDraftButton: UIButton!
        @IBOutlet weak var MoreOptionsContainerView: UIView!
        @IBOutlet weak var moreOptionsIcon: UIImageView!
        
        var CurMail:EnvelopeEntity!
        var delegate:MailCellActionDelegate?
        var expanded:Bool = false
        var msgBodyHeight:CGFloat = 0
        
        override func awakeFromNib() {
                super.awakeFromNib()
                setupView()
        }
        
        @IBAction func OnMorePressed(_ sender: UIButton) {
                delegate?.popoverContacts(self.CurMail, self.MoreInfoContainerView)
        }
        
        @objc func handleTap(_ gestureRecognizer:UITapGestureRecognizer){
                guard let delegate = self.delegate else {
                        return
                }
                self.expanded = !expanded
                if self.expanded{
                        self.HeightConstraint.constant = self.msgBodyHeight
                }else{
                        self.HeightConstraint.constant = 0
                }
                delegate.tableViewReload(self)
                
//                let touchPt = gestureRecognizer.location(in: self.contentView)
//                guard touchPt.y < 103.0 + self.msgBodyHeight,
//                    let tappedView = self.hitTest(touchPt, with: nil) else {
//                    return
//                }
//                if tappedView == self.MoreOptionsContainerView {
//                        delegate.showOperationsForMail(self, self.MoreOptionsContainerView)
//                } else if tappedView == self.MoreInfoContainerView || tappedView == self.ContactsLabel {
//                        delegate.popoverContacts(self, self.MoreInfoContainerView)
//                } else {
//                        delegate.tableViewReload(self)
//                }
        }
        
        func setupView(){
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                tap.numberOfTapsRequired = 1
                tap.numberOfTouchesRequired = 1
                self.addGestureRecognizer(tap)
                backGroundView.layer.borderWidth = 1
                backGroundView.layer.borderColor = UIColor(r: 212, g: 204, b: 204, a: 1).cgColor
                AttachmentTableView.isHidden = true
                ContactsLabel.isHidden = true
                MiniAttachmentImageView.isHidden = true
                MailBodyView.editingEnabled = false//.enableMode = .disabled
                MailBodyView.delegate = self
        }
        
        func setupContent(mail: EnvelopeEntity) {
                self.CurMail = mail
               
                AvatarImageView.image = mail.addrImge
                DateLabel.text = mail.dateStr
                let size = DateLabel.sizeThatFits(CGSize(width: 100.0, height: 19))
                DateWidthConstrant.constant = size.width
//                DeleteDraftButton.isHidden = mail.isSent
                
                previewLabel.isHidden = self.expanded
                MoreInfoContainerView.isHidden = !self.expanded
                MoreOptionsContainerView.isHidden = !self.expanded
                ContactsLabel.isHidden = !self.expanded
                ContactsCollapseLabel.text = mail.fromName
                
                if self.expanded{
                        if mail.isInbox{
                                ContactsLabel.text  = "To Me".locStr
                        }else{
                                ContactsLabel.text = "To".locStr + " \(mail.Tos.first?.key ?? "")"
                        }
                        
                        let size = ContactsLabel.sizeThatFits(CGSize(width: RECIPIENTS_MAX_WIDTH, height: 22.0))
                        ContactsLabelWidthConstrant.constant = size.width > RECIPIENTS_MAX_WIDTH ? RECIPIENTS_MAX_WIDTH : size.width
                }
                
                if mail.isDecrypted{
                        MailBodyView.html = mail.rawBody ?? ""
                        previewLabel.text = String(mail.rawBody?.prefix(20) ?? "")
                }else{
                        MailBodyView.html = mail.pinCodedMsg ?? ""
                        previewLabel.text = "Crypted Mail".locStr
                }
        }
}

extension EmailDetailsTableViewCell: RichEditorDelegate{
        
        func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
               self.msgBodyHeight = CGFloat(height)
        }
}

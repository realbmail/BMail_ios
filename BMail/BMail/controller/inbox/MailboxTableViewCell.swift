//
//  MailboxTableViewCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/29.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class MailboxTableViewCell: UITableViewCell {
        
        @IBOutlet weak var attachImage: UIImageView!
        @IBOutlet weak var time: UILabel!
        @IBOutlet weak var starredImage: UIImageView!
        @IBOutlet weak var encryptedImage: UIImageView!
        @IBOutlet weak var avatarImageView: UIImageView!
        @IBOutlet weak var sender: UILabel!
        @IBOutlet weak var title: UILabel!
        
        @IBOutlet weak var attachmentConstraint: NSLayoutConstraint!
        @IBOutlet weak var starConstraint: NSLayoutConstraint!
        @IBOutlet weak var timeConstraint: NSLayoutConstraint!
        @IBOutlet weak var titleHorSpaceConstraint: NSLayoutConstraint!
        
        override func awakeFromNib() {
                super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
                super.setSelected(selected, animated: animated)
        }
        
        func fullfillData(data:EnvelopeEntity){
                
                self.sender.text = data.fromName
                attachImage.isHidden = !data.hasAttachMent()
                starredImage.isHidden = !data.isStarred
                
                self.time.text = data.dateStr
                if data.isDecrypted{
                        self.title.text = data.rawSubject ?? "No Subject".locStr
                }else{
                        if data.isDraft{
                                self.title.text = data.rawSubject ?? "No Subject"
                        }else{
                                self.title.text = "******".locStr
                        }
                }
                if data.isUnread{
                        self.title.font = self.title.font.bold(size: 20)
                }else{
                        self.title.font = self.title.font.unBold(size: 16)
                }
                
                let size = time.sizeThatFits(CGSize(width: 100.0, height: 19))
                timeConstraint.constant = size.width
                avatarImageView.image = data.addrImge
        }
}

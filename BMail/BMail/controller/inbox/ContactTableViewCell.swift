//
//  ContactTableViewCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/6.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import BmailLib

class ContactTableViewCell: UITableViewCell {

        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var emailLabel: UILabel!
        @IBOutlet weak var avatarImageView: UIImageView!
    
        override func awakeFromNib() {
                super.awakeFromNib()
                nameLabel.textColor = UIColor(red: 55/255, green: 58/255, blue: 69/255, alpha: 1)
                emailLabel.textColor = UIColor(red: 106/255, green: 112/255, blue: 126/255, alpha: 1)
                backgroundColor = .clear
        }
        
        public func FullFillData(_ contact:BmailContact){
                self.nameLabel?.text = contact.DisplayName
                self.emailLabel?.text = contact.MailName

                if let img_data = BmailLibMailIcon(contact.MailName){
                        self.avatarImageView.image = UIImage.init(data: img_data)
                }
        }
}

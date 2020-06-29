//
//  ContactItemTableViewCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/6/20.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import BmailLib

class ContactItemTableViewCell: UITableViewCell {

        @IBOutlet weak var IDImageView: UIImageView!
        @IBOutlet weak var CnameLabel: UILabel!
        @IBOutlet weak var MailNameLabel: UILabel!
        @IBOutlet weak var MailAddrLabel: UILabel!
        
        
        override func awakeFromNib() {
                super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
                super.setSelected(selected, animated: animated)
        }
        
        func populate(contact:BmailContact) {
                self.CnameLabel.text = contact.DisplayName
                self.MailAddrLabel.text = contact.MailAddr
                self.MailNameLabel.text = contact.MailName
                
                guard let img_data = BmailLibMailIcon(contact.MailName) else{
                        return
                }
                
                self.IDImageView.image = UIImage.init(data: img_data)
        }
}

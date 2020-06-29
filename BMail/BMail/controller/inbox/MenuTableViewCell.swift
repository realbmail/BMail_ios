//
//  MenuTableViewCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/29.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

        @IBOutlet weak var titleImageView: UIImageView!
        @IBOutlet weak var titleTxtLabel: UILabel!
        @IBOutlet weak var unreadNoLabel: UILabel!
        
        var isUnreadTittled: Bool = false
        var actionType:MailActionType!
        override func awakeFromNib() {
                super.awakeFromNib()
                unreadNoLabel.layer.masksToBounds = true;
                unreadNoLabel.layer.cornerRadius = 12;
                unreadNoLabel.text = "0";
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
                super.setSelected(selected, animated: animated)
        }
        
        func configCell(_ indx:Int, section:Int){
                isUnreadTittled = section == 0
                let x = section * (MailActionType.Help.rawValue) + indx
                
                actionType = MailActionType(rawValue: x)
                self.titleTxtLabel.text = actionType.Name
                let (icon, hight_icon) = actionType.IcoinName()
                self.titleImageView.image = UIImage.init(named: icon)
                self.titleImageView.highlightedImage = UIImage.init(named: hight_icon)
        }
        
        func configUnreadCount(){
                
                guard let counter =  MailManager.counter[actionType],
                        isUnreadTittled,
                        counter > 0 else{
                        
                        self.unreadNoLabel.isHidden = true
                        return
                }
                
                self.unreadNoLabel.isHidden = false
                self.unreadNoLabel.text = "\(counter)"
        }
}

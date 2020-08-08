//
//  StampTableViewCell.swift
//  BMail
//
//  Created by wesley on 2020/8/8.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class StampTableViewCell: UITableViewCell {
        
        @IBOutlet weak var SBalanceLbl: UILabel!
        @IBOutlet weak var SActiveLbl: UILabel!
        @IBOutlet weak var SCreditLbl: UILabel!
        @IBOutlet weak var SIssuerAddrLbl: UILabel!
        @IBOutlet weak var SMailTokenName: UILabel!
        @IBOutlet weak var SMailTokenIconImg: UIImageView!
        
        
        override func awakeFromNib() {
                super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
                super.setSelected(selected, animated: animated)
        }
        
        func populate(stamp:Stamp) {
        }
        
        @IBAction func SIssuerQRShow(_ sender: UIButton) {
        }
}

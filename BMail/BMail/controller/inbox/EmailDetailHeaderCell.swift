//
//  EmailDetailHeaderCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/20.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import TagListView

class EmailDetailHeaderCell: UITableViewHeaderFooterView {
       
        @IBOutlet weak var subjectLabel: UILabel!
        @IBOutlet weak var TopMarginView: UIView!
        @IBOutlet weak var labelsListView: TagListView!
        @IBOutlet weak var BottomMarginView: UIView!
        @IBOutlet weak var subjectHeightConstraint: NSLayoutConstraint!
        
        override func awakeFromNib() {
                super.awakeFromNib()
                self.backgroundView = UIView(frame: self.bounds)
                self.backgroundView!.backgroundColor = UIColor.init(r: 247, g: 247, b: 248, a: 1)// UIColor.red//
        }
        
//        func addLabels(_ labels: [Label]){
//            labelsListView.removeAllTags()
//            var starredImage = #imageLiteral(resourceName: "starred_empty")
//            for label in labels {
//                guard label.id != SystemLabel.inbox.id && label.id != SystemLabel.sent.id else {
//                    continue
//                }
//                guard label.id != SystemLabel.starred.id else {
//                    starredImage = #imageLiteral(resourceName: "starred_full")
//                    continue
//                }
//                let tag = labelsListView.addTag(label.localized)
//                tag.tagBackgroundColor = UIColor(hex: label.color)
//            }
//            labelsListView.invalidateIntrinsicContentSize()
//            starButton.setImage(starredImage, for: .normal)
//            let hideTagsViews = labelsListView.tagViews.count == 0
//            marginTopView.isHidden = hideTagsViews
//            marginBottomView.isHidden = hideTagsViews
//            labelsListView.isHidden = hideTagsViews
//        }
        
        func setSubject(_ subject: String){
                let mySubject = subject.isEmpty ? "No Subject".locStr : subject
                subjectLabel.text = mySubject
                subjectLabel.numberOfLines = 0
                let myHeight = getLabelHeight(mySubject, width: subjectLabel.frame.width, fontSize: 18.0)
                subjectHeightConstraint.constant = myHeight
        }
        
        @IBAction func onStarButtonPressed(_ sender: UIButton) {
        }
}

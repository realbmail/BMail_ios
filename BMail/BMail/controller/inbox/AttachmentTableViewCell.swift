//
//  AttachmentTableViewCell.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/6.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import Foundation

protocol AttachmentTableViewCellDelegate {
    func tableViewCellDidTapReadOnly(_ cell:AttachmentTableViewCell)
    func tableViewCellDidTapPassword(_ cell:AttachmentTableViewCell)
    func tableViewCellDidTapRemove(_ cell:AttachmentTableViewCell)
    func tableViewCellDidTap(_ cell:AttachmentTableViewCell)
}

class AttachmentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var contentContainerView: UIView!
    
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var successImageView: UIImageView!
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    var holdGestureRecognizer:UILongPressGestureRecognizer!
    var delegate:AttachmentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentContainerView.layer.borderWidth = 1.5
        self.contentContainerView.layer.cornerRadius = 6.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tap)
        self.tapGestureRecognizer = tap
        
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.addGestureRecognizer(hold)
        self.holdGestureRecognizer = hold
        
        self.buttonClose.addTarget(self, action: #selector(didPressCloseButton(_:)), for: .touchUpInside)
        applyTheme()
    }
    
    func applyTheme() {
        backgroundColor = .clear
        contentContainerView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        contentContainerView.layer.borderColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        viewClose.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        viewClose.layer.borderColor = UIColor(red: 55/255, green: 58/255, blue: 69/255, alpha: 1).cgColor
        nameLabel.textColor = UIColor(red: 55/255, green: 58/255, blue: 69/255, alpha: 1)
        sizeLabel.textColor = UIColor(red: 106/255, green: 112/255, blue: 126/255, alpha: 1)
        buttonClose.imageView?.tintColor = UIColor(red: 55/255, green: 58/255, blue: 69/255, alpha: 1)
    }
    
    @objc func didPressCloseButton(_ view: UIButton){
        guard let delegate = self.delegate else {
            return
        }
        delegate.tableViewCellDidTapRemove(self)
    }
    
    @objc func handleTap(_ gestureRecognizer:UITapGestureRecognizer){
        guard let delegate = self.delegate else {
            return
        }
        delegate.tableViewCellDidTap(self)
    }
    
    @objc func handleLongPress(_ gestureRecognizer:UITapGestureRecognizer){
        
    }
    
    func setMarkIcon(success: Bool){
        successImageView.isHidden = false
        guard success else {
            successImageView.image = #imageLiteral(resourceName: "mark-error")
            successImageView.backgroundColor = UIColor(red: 221/255, green: 64/255, blue: 64/255, alpha: 1)
            return
        }
        progressView.isHidden = true
        successImageView.image = #imageLiteral(resourceName: "mark-success")
        successImageView.backgroundColor = UIColor(red: 0, green: 145/255, blue: 255/255, alpha: 1)
    }
}

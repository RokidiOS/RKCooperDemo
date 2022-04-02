//
//  ContactCell.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

enum CellState: Int {
    case offline           = 0 // 离线
    case offlineAvailable  = 1 // 离线可以发起呼叫
    case online            = 2 // 在线
    case selected          = 3 // 选中
    case onlineBusy        = 4 // 在线正忙
}

class ContactCell: UITableViewCell {
    
    // 头像
    var avatarImageButton: UIButton!
    // 名字
    var nameLabel: UILabel!
    // 状态
    var statePointView: UIView!
    var stateLabel: UILabel!
    // 右侧选择框
    var pickImageView: UIImageView!
    // 底部横线
    var lineView: UIView!
    // 状态
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        avatarImageButton = UIButton(type: .custom)
        avatarImageButton.layer.cornerRadius = 22
        avatarImageButton.layer.masksToBounds = true
        self.contentView.addSubview(avatarImageButton)
        
        nameLabel = UILabel.init()
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = UIColor(hex: 0x000000)
        self.contentView.addSubview(nameLabel)
        
        statePointView = UIView()
        statePointView.layer.cornerRadius = 2.5
        statePointView.backgroundColor = UIColor(hex: 0x909090)
        self.contentView.addSubview(statePointView)
        
        stateLabel = UILabel()
        stateLabel.font = .systemFont(ofSize: 12)
        stateLabel.textColor = UIColor(hex: 0x909090)
        self.contentView.addSubview(stateLabel)
        
        pickImageView = UIImageView.init()
        let accImage = UIImage(named: "rk_checkbox_n")
        pickImageView.image = accImage
        self.contentView.addSubview(pickImageView)
        
        lineView = UIView.init()
        lineView.backgroundColor = UIColor(hex: 0xF3F3F3)
        self.contentView.addSubview(lineView)
        
        avatarImageButton.snp.makeConstraints { (make) in
            make.size.equalTo(44)
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(13)
            make.left.equalTo(avatarImageButton.snp.right).offset(10)
            make.right.equalTo(pickImageView.snp.left).offset(-10)
            make.height.equalTo(20)
        }
        
        statePointView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.size.equalTo(5)
            make.centerY.equalTo(stateLabel)
        }
        
        stateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(statePointView.snp.right).offset(5)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        
        pickImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func getStateAttributedText(_ text: String) -> NSMutableAttributedString {
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)] as [NSAttributedString.Key : Any]
        let attString = NSMutableAttributedString(string: text)
        attString.addAttributes(att, range:NSRange.init(location: 0, length: 1))
        return attString
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var showChoosed = false {
        didSet {
            guard let model = model else { return }
            if showChoosed {
                pickImageView.image = UIImage(named: "rk_checkbox_s")
            } else {
                pickImageView.image = UIImage(named: "rk_checkbox_n")
            }
            pickImageView.isHidden = false
//            !model.status
         
        }
    }
    
    var model: ContactModel? {
        didSet {
            guard let contactInfo = model else { return }
       
            let nameStr = contactInfo.realName
            if contactInfo.postName.count > 0 {
                // 判断是否需要走展示岗位
                let postName = "｜" + contactInfo.postName
                let nameAttribute = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x000000),
                                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
                let postNameAttribute = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x999999),
                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
                let attStr = NSMutableAttributedString(string: nameStr + postName)
                attStr.addAttributes(nameAttribute, range:NSRange.init(location: 0, length: nameStr.count))
                attStr.addAttributes(postNameAttribute, range: NSRange.init(location: nameStr.count, length: postName.count))
                
                nameLabel.attributedText = attStr
                
            } else {
                nameLabel.text = nameStr
            }
            
        
            if contactInfo.headUrl.count > 0 {
                avatarImageButton.kf.setImage(with: URL(string: contactInfo.headUrl), for: .normal)
            } else {
                let avatarImage = UIImage(named: "book_avatar_bg_n")
                avatarImageButton.setImage(avatarImage, for: .normal)
            }
       
        }
    }
}

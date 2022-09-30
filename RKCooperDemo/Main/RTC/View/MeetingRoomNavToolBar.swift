//
//  MeetingRoomNavToolBar.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/20.
//

import UIKit
import RKIUtils
import QMUIKit

protocol MeetingRoomNavToolBarDelegate: NSObjectProtocol {
    // MARK: - 缩放
    func scaleRoomButtonAction(_ sender: UIButton)
}

class MeetingRoomNavToolBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()  {
        
        //        self.addSubview(scaleRoomButton)
        self.addSubview(roomNameLabel)
        self.addSubview(roomTimeLabel)
        self.addSubview(roomLabelLine)
        
        //        scaleRoomButton.snp.makeConstraints { (make) in
        //            make.left.equalToSuperview()
        //            make.width.height.equalTo(30)
        //            make.centerY.equalToSuperview()
        //        }
        
        roomNameLabel.snp.makeConstraints { (make) in
            make.top.height.equalToSuperview()
            make.right.equalTo(self.snp.centerX).offset(-10)
        }
        
        roomTimeLabel.snp.makeConstraints { (make) in
            make.top.height.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(10)
        }
        
        roomLabelLine.snp.makeConstraints { (make) in
            make.width.equalTo(1)
            make.height.equalTo(12)
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
    @objc func scaleRoomButtonAction(_ sender: UIButton) {
        //        delegate?.scaleRoomButtonAction(sender)
    }
    
    @objc func copyRoomId() {
        if let roomId = roomNameLabel.text {
            let pasteboard = UIPasteboard.general
//            pasteboard.setValue(roomId  , forPasteboardType: )
            pasteboard.string = roomId
            QMUITips.showSucceed("copy roomId success")
        }
      
        
    }
    
    // 缩放按钮
    lazy var scaleRoomButton: UIButton = {
        let button = UIButton(type:.custom)
        let normalImage = UIImage(named: "ic_room_scale")
        let selectedImage = UIImage(named: "ic_room_scale")
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.addTarget(self, action: #selector(scaleRoomButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var roomNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = RKFont.font_tipText
        label.textColor = .white
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(copyRoomId))
        pressGesture.minimumPressDuration = 2.0
        label.addGestureRecognizer(pressGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var roomTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = RKFont.font_tipText
        label.textColor = .white
        return label
    }()
    
    lazy var roomLabelLine: UIView = {
        let view = UIView()
        view.backgroundColor = RKColor.lineClr
        return view
    }()
    
}

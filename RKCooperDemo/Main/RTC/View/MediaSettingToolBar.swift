//
//  MediaSettingToolBar.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/19.
//

import UIKit
import RKIUtils

@objc enum SettingButtonAction: Int {
    case shutDown    = 1  // 退出
    case pop         = 2  // 返回
    case audio       = 3  // 声音
    case trumpet     = 4  // 扬声器
    case video       = 5  // 视频
    case invite      = 6  // 邀请
    case setting     = 7  // 设置
    case tools       = 8  // 工具
    case mute        = 9  // 一键静音
}

protocol MediaSettingToolBarDelegate: NSObjectProtocol {
    
    func settingToolBtnAction(_ settingBtnAction: SettingButtonAction)
    
    func settingToolHiddenBtnAction(_ button: UIButton)

}

class MediaSettingToolBar: UIView {
    
    weak var delegate: MediaSettingToolBarDelegate?
    
    var hiddenButton: UIButton!
    
    var popButton: UIButton!
    
    var audioButton: UIButton!
    
    var trumpetButton: UIButton!
    
    var videoButton: UIButton!
    
    var muteButton: UIButton!
    
    var settingButtons: [SettingButtonAction] = [] {
        didSet {
            setupView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if hiddenButton.point(inside: self.convert(point, to: hiddenButton), with: event) {
            return hiddenButton
        }
        
        return super.hitTest(point,with: event)
    }
    
    func setupView()  {
        
        guard settingButtons.count > 0 else {
            return
        }
        
        self.subviews.reversed().forEach { (subView) in
            subView.removeFromSuperview()
        }
        
        hiddenButton = UIButton(type: .custom)
        let normalImage = UIImage(named: "ic_call_room_member_detail_tool_close")
        let selectedImage = UIImage(named: "ic_call_room_member_detail_tool_open")
        hiddenButton.setImage(normalImage, for: .normal)
        hiddenButton.setImage(selectedImage, for: .selected)
        hiddenButton.addTarget(self, action: #selector(hiddenButtonAction), for: .touchUpInside)
        self.addSubview(hiddenButton)
        hiddenButton.snp.makeConstraints { (make) in
            make.left.equalTo(-24)
            make.width.equalTo(24)
            make.height.equalTo(42)
            make.centerY.equalToSuperview()
        }
        
        let settingBar = UIView()
        settingBar.backgroundColor = .init(hex: 0x000000, alpha: 0.75)
        self.addSubview(settingBar)
        
        settingBar.snp.makeConstraints { (make) in
            make.top.height.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        let marginTop = 40 - settingButtons.count * 4
        let itemWidth = 48
        
        let contentView = UIView()
        settingBar.addSubview(contentView)
        contentView.snp.makeConstraints({ (make) in
            make.width.equalTo(itemWidth)
            make.height.equalTo(settingButtons.count * (marginTop + itemWidth) - marginTop)
            make.left.equalTo(13)
            make.centerY.equalToSuperview()
        })
        
        for i in 0 ..< settingButtons.count {
            let item: SettingButtonAction = settingButtons[i]
            var button: UIButton
            switch item {
            case .shutDown:
                button = createItemButton("media_setting_exit", "media_setting_exit", #selector(buttonAction(_:)))
            case .pop:
                button = createItemButton("midea_setting_pop", "midea_setting_pop", #selector(buttonAction(_:)))
                popButton = button
            case .audio:
                button = createItemButton("media_setting_mic_on", "media_setting_mic_off", #selector(buttonAction(_:)))
                audioButton = button
            case .trumpet:
                button = createItemButton("media_setting_trumpet_on", "media_setting_trumpet_off", #selector(buttonAction(_:)))
                trumpetButton = button
            case .video:
                button = createItemButton("media_setting_camera_on", "media_setting_camera_off", #selector(buttonAction(_:)))
                videoButton = button
            case .invite:
                button = createItemButton("media_setting_invite_users", "media_setting_invite_users", #selector(buttonAction(_:)))
            case .setting:
                button = createItemButton("media_setting_set", "media_setting_set", #selector(buttonAction(_:)))
            case .tools:
                button = createItemButton("media_setting_tools", "media_setting_tools", #selector(buttonAction(_:)))
            case .mute:
                button = createItemButton("media_setting_mute_on", "media_setting_mute_on", #selector(buttonAction(_:)))
                muteButton = button
            }
            
            button.tag = item.rawValue
            contentView.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(i * (marginTop + itemWidth))
                make.size.equalTo(itemWidth)
                make.centerX.equalToSuperview()
            })
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        guard let action = SettingButtonAction(rawValue: sender.tag)  else {
            return
        }
        
        switch action {
        case .audio, .trumpet:
            sender.isSelected = !sender.isSelected
        default: break
        }
        delegate?.settingToolBtnAction(action)
    }
    
    @objc func hiddenButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.snp.updateConstraints { (make) in
                make.right.equalToSuperview().offset(70)
            }
        } else {
            self.snp.updateConstraints { (make) in
                make.right.equalTo(0)
            }
        }
        
        delegate?.settingToolHiddenBtnAction(sender)
    }
    
    fileprivate func createItemButton(_ imageName : String,
                                      _ selectedImageName :String,
                                      _ action : Selector) -> UIButton {
        let button = ItemButton(type:.custom)
        let normalImage = UIImage(named: imageName)
        let selectedImage = UIImage(named: selectedImageName)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.imageView?.contentMode = .center
        return button
    }
}

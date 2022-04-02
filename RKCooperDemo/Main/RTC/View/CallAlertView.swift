//
//  AlertView.swift
//  iOSRokid
//
//  Created by 张小饼 on 2021/3/31.
//

import UIKit
import RKIUtils

enum AlertViewType {
    case camera       // 摄像头
    case member       // 会议内邀请
    case setting      // 设置项
    case tools        // 工具栏
    case doodle       // 电子白板
    case imageDoodle   // 冻屏标注
    case share        // 屏幕共享
    case slam         // AR标注
    case pointVideo   // 视频点选
}


enum AlertViewActionType {
    case camera_switch
    case camera_on_off
    case member_invite
    case member_audio_off
    case tool_share
    case tool_doodle
    case back
    case shutdown_doodle
    case shutdown_imageDoodle
    case shutdown_screen
    case shutdown_slam
    case shutdown_pointVideo ///< 关闭视频点选
    
}


protocol AlertViewDelegate: NSObjectProtocol {
    func alertViewAction(_ action: AlertViewActionType)
}

public class CallAlertView: UIView {
    
    var type: AlertViewType = .camera
    weak var delegate: AlertViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()  {
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSubMenu(sender:))))
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.7)
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.leftButton)
        self.contentView.addSubview(self.rightButton)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.snp.makeConstraints { (make) in
            make.width.equalTo(266)
            make.height.equalTo(160)
            make.centerX.centerY.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.left.right.equalToSuperview()
        }
        
        self.leftButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(100)
            make.height.equalTo(70)
            make.right.equalTo(self.contentView.snp.centerX)
        }
        
        self.rightButton.snp.makeConstraints { (make) in
            make.bottom.width.height.equalTo(self.leftButton)
            make.left.equalTo(self.contentView.snp.centerX)
        }
    }
    
    func showContentView(type: AlertViewType, _ isSelf: Bool = false) {
        self.type = type
        switch type {
        case .camera:
            self.titleLabel.text = "摄像头管理"
            setupButton(self.leftButton, "切换摄像头", "ic_switch_camera")
            if MeetingManager.shared.cameraSwitch {
                setupButton(self.rightButton, "已开启", "ic_switch_camera_on")
            } else {
                setupButton(self.rightButton, "已关闭", "ic_switch_camera_off")
            }
        case .member:
            self.titleLabel.text = "与会人员管理"
            setupButton(self.leftButton, "邀请加入协作", "ic_switch_invite")
            setupButton(self.rightButton, "全员静音", "media_setting_mute_on")
        case .setting:
            self.titleLabel.text = "设置"
            setupButton(self.leftButton, "屏幕共享", "ic_switch_share")
            setupButton(self.rightButton, "电子白板", "ic_switch_mark")
        case .tools:
            self.titleLabel.text = "工具箱"
            setupButton(self.leftButton, "屏幕共享", "ic_switch_share")
            setupButton(self.rightButton, "电子白板", "ic_switch_mark")
        case .share:
            self.titleLabel.text = "返回首页 或 结束“屏幕共享”？"
            setupButton(self.leftButton, "返回首页", "ic_switch_back")
            setupButton(self.rightButton, "退出屏幕共享", isSelf ? "ic_switch_shutdown_self": "ic_switch_shutdown")
        case .doodle:
            self.titleLabel.text = "返回首页 或 结束“电子白板”？"
            setupButton(self.leftButton, "返回首页", "ic_switch_back")
            setupButton(self.rightButton, "结束电子白板", isSelf ? "ic_switch_shutdown_self": "ic_switch_shutdown")
        case .imageDoodle:
            self.titleLabel.text = "返回首页 或 结束“冻屏标注”？"
            setupButton(self.leftButton, "返回首页", "ic_switch_back")
            setupButton(self.rightButton, "退出冻屏标注", isSelf ? "ic_switch_shutdown_self": "ic_switch_shutdown")
        case .slam:
            self.titleLabel.text = "返回首页 或 结束“AR标注”？"
            setupButton(self.leftButton, "返回首页", "ic_switch_back")
            setupButton(self.rightButton, "退出AR标注", isSelf ? "ic_switch_shutdown_self": "ic_switch_shutdown")
        case .pointVideo:
            self.titleLabel.text = "返回首页 或 结束“视频点选”？"
            setupButton(self.leftButton, "返回首页", "ic_switch_back")
            setupButton(self.rightButton, "结束视频点选", isSelf ? "ic_switch_shutdown_self": "ic_switch_shutdown")
        }
        
        UIView.animate(withDuration: 0.35) {
            self.alpha = 1
        }
    }
    
    // MARK: - 关闭Alert
    @objc func hideSubMenu(sender: UITapGestureRecognizer?) {
        UIView.animate(withDuration: 0.35) {
            self.alpha = 0
        } completion: { (_) in
            self.delegate = nil
            self.removeFromSuperview()
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = RKColor.BgColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 2
        label.font = RKFont.font_nomalText
        label.textAlignment = .center
        label.textColor = UIColor(white: 1, alpha: 0.85)
        return label
    }()
    
    lazy var leftButton: AlertButton = {
        AlertButton(type:.custom)
    }()
    
    lazy var rightButton: AlertButton = {
        AlertButton(type:.custom)
    }()
    
    func setupButton(_ button : AlertButton,
                     _ title : String,
                     _ imageName : String) {
        button.contentMode = .scaleAspectFit
        button.setTitle(title, for: .normal)
        button.titleLabel!.font = RKFont.font_tipText
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        let normalImage = UIImage(named: imageName)
        button.setImage(normalImage, for: .normal)
        button.addTarget(self, action: #selector(actionBtnClicked(_:)), for: .touchUpInside)
        
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @objc func actionBtnClicked(_ sender: AlertButton) {
        let idx = (sender == self.leftButton) ? 0 : 1
        var actions: [AlertViewActionType] = []
        switch type {
        case .camera:
            actions.append(.camera_switch)
            actions.append(.camera_on_off)
        case .member:
            actions.append(.member_invite)
            actions.append(.member_audio_off)
        case .setting:
            actions.append(.tool_share)
            actions.append(.tool_doodle)
        case .tools:
            actions.append(.tool_share)
            actions.append(.tool_doodle)
        case .share:
            actions.append(.back)
            actions.append(.shutdown_screen)
        case .doodle:
            actions.append(.back)
            actions.append(.shutdown_doodle)
        case .imageDoodle:
            actions.append(.back)
            actions.append(.shutdown_imageDoodle)
        case .slam:
            actions.append(.back)
            actions.append(.shutdown_slam)
        case .pointVideo:
            actions.append(.back)
            actions.append(.shutdown_pointVideo)
            
        }
        
        let action = actions[idx]
        sender.isSelected = !sender.isSelected
        self.delegate?.alertViewAction(action)
        hideSubMenu(sender: nil)
    }
    
    @objc func customActionBtnClicked(_ sender: UIButton) {
        
    }
}

class AlertButton: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(x: contentRect.width / 2 - 24, y: 0, width: 48, height: 48)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(x: 0, y: 50, width: contentRect.width, height: contentRect.height - 50)
    }
}


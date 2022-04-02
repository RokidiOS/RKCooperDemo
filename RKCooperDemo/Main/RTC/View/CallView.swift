//
//  CallSettingView.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/14.
//

import UIKit
import RKIUtils

protocol CallViewDelegate: NSObjectProtocol {
    
    // MARK: - 语音开关
    func audioBtnAction(_ sender: UIButton)
    
    // MARK: - 摄像头开关
    func videoBtnAction(_ sender: UIButton)
    
    // MARK: - 扬声器开关
    func trumpetBtnAction(_ sender: UIButton)
    
    // MARK: - 云端录制开关
    func cloudRecordBtnAction(_ sender: UIButton)

    // MARK: - 云端录制类型
    func cloudRecordType(_ cloudRecordType: RKCloudRecordType)
    
    // MARK: - 开始协作
    func startBtnAction(_ sender: UIButton)
}

enum RKCloudRecordType: String {
    case low    = "360P"
    case middle = "720P"
    case high   = "1080P"
}

class CallView: UIView {
    
    weak var delegate: CallViewDelegate?
    
    var titleLabel = UILabel()
        
    var callSettingContentView = UIView()
    
    var cloudRecordBgView = UIView()
    
    var cloudRecordType:RKCloudRecordType = .middle {
        didSet {
            cloudRecordBgView.subviews.forEach { (button) in
                if let btn = button as? UIButton {
                    if let titile = btn.titleLabel?.text,
                       cloudRecordType.rawValue == titile {
                        btn.isSelected = true
                        btn.layer.borderColor = UIColor.clear.cgColor
                        btn.backgroundColor = UIColor(hex: 0x1964FA, alpha: 1)
                    } else {
                        btn.isSelected = false
                        btn.layer.borderWidth = 0.5
                        btn.layer.borderColor = UIColor(hex: 0xFFFFFF, alpha: 0.6).cgColor
                        btn.backgroundColor = .clear
                    }
                }
            }
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
    
    func setupView()  {
        
        titleLabel.font = RKFont.font_thirdTitle_bold
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        // 功能按钮配置选项
        self.addSubview(callSettingContentView)
        callSettingContentView.snp.makeConstraints { (make) in
            make.width.equalTo(270)
            make.height.equalTo(90)
            make.bottom.equalTo(self.snp.centerY).offset(20)
            make.centerX.equalToSuperview()
        }
        // 语音开关
        callSettingContentView.addSubview(self.audioButton)
        audioButton.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(90)
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
        }
        // 视频开关
        callSettingContentView.addSubview(self.videoButton)
        videoButton.snp.makeConstraints { (make) in
            make.bottom.width.height.equalTo(audioButton)
            make.left.equalTo(audioButton.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        // 扬声器开关
        callSettingContentView.addSubview(self.trumpetButton)
        trumpetButton.snp.makeConstraints { (make) in
            make.bottom.width.height.equalTo(audioButton)
            make.left.equalTo(videoButton.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        // 云端录制
        callSettingContentView.addSubview(self.cloudRecordButton)
        cloudRecordButton.snp.makeConstraints { (make) in
            make.bottom.width.height.equalTo(audioButton)
            make.left.equalTo(trumpetButton.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        // 分割线
        let lineH = UIView()
        lineH.backgroundColor = UIColor(hex: 0xFFFFFF, alpha: 0.45)
        self.addSubview(lineH)
        lineH.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.centerY).offset(30)
            make.width.equalTo(258)
            make.height.equalTo(0.5)
            make.centerX.equalToSuperview()
        }
        
        // 录制选项
        self.addSubview(cloudRecordBgView)
        cloudRecordBgView.snp.makeConstraints { (make) in
            make.top.equalTo(lineH.snp.bottom).offset(15)
            make.width.equalTo(210)
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
        }
        
        let cloudRecordTypes = [RKCloudRecordType.low,
                                RKCloudRecordType.middle,
                                RKCloudRecordType.high]
        
        for i in 0 ..< cloudRecordTypes.count {
            let button = UIButton(type: .custom)
            button.layer.cornerRadius = 12
            button.titleLabel?.font = RKFont.font_nomalText
            button.setTitleColor(UIColor(hex: 0xFFFFFF, alpha: 0.6), for: .normal)
            button.setTitleColor(UIColor(hex: 0xFFFFFF, alpha: 1), for: .selected)
            button.backgroundColor = .clear
            button.setTitle(cloudRecordTypes[i].rawValue, for: .normal)
            button.addTarget(self, action: #selector(cloudRecordButtonAction(_:)), for: .touchUpInside)
            cloudRecordBgView.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.width.equalTo(54)
                make.height.equalToSuperview()
                make.left.equalTo(i * 74)
                make.centerY.equalToSuperview()
            }
        }
        // 开始协作按钮
        self.addSubview(self.startButton)
        startButton.snp.makeConstraints { (make) in
            make.bottomMargin.equalTo(-20)
            make.height.equalTo(44)
            make.width.equalTo(300)
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func cloudRecordButtonAction(_ sender: UIButton) {
        cloudRecordType = RKCloudRecordType(rawValue: sender.titleLabel!.text!)!
        delegate?.cloudRecordType(cloudRecordType)
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        switch sender {
        case self.audioButton:
            delegate?.audioBtnAction(sender)
        case self.videoButton:
            delegate?.videoBtnAction(sender)
        case self.trumpetButton:
            delegate?.trumpetBtnAction(sender)
        case self.cloudRecordButton:
            delegate?.cloudRecordBtnAction(sender)
        case self.startButton:
            delegate?.startBtnAction(sender)
        default: break
        }
    }
    
    lazy var audioButton: UIButton = {
        let button = createItemButton("已开启", "已关闭", "ic_call_mic_on", "ic_call_mic_off", 11, #selector(buttonAction(_:)))
        return button
    }()
    
    lazy var videoButton: UIButton = {
        let button = createItemButton("已开启", "已关闭", "ic_call_camera_on", "ic_call_camera_off", 11, #selector(buttonAction(_:)))
        return button
    }()
    
    lazy var trumpetButton: UIButton = {
        let button = createItemButton("免提已开", "听筒已开", "ic_call_trumpet_on", "ic_call_trumpet_off", 11, #selector(buttonAction(_:)))
        return button
    }()
    
    lazy var cloudRecordButton: UIButton = {
        let button = createItemButton("云端录制", "云端录制关闭", "ic_switch_cloud_record_on", "ic_switch_cloud_record_off", 11, #selector(buttonAction(_:)))
        button.isHidden = true
        return button
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton(type:.custom)
        button.setTitle("开始协作", for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(UIColor.init(hex: 0x1964FA), for: .normal)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        button.addTarget(self, action:#selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    func createItemButton(_ title : String,
                          _ selectedTitle :String,
                          _ imageName : String,
                          _ selectedImageName :String,
                          _ fontSize : CGFloat,
                          _ action : Selector) -> UIButton {
        let button = ItemButton(type:.custom)
        button.setTitle(title, for: .normal)
        button.setTitle(selectedTitle, for: .selected)
        button.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        button.setTitleColor(.white, for: .normal)
        let normalImage = UIImage(named: imageName)
        let selectedImage = UIImage(named: selectedImageName)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }
}

class ItemButton: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(x: 0, y: 0, width: contentRect.width, height: contentRect.width)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        CGRect(x: 0, y: contentRect.width, width: contentRect.width, height: contentRect.height - contentRect.width)
    }
}

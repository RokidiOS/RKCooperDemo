//
//  CallPreVC.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//  发起会议前置页面

import UIKit
import RKIUtils
import RKCooperationCore
import QMUIKit

class CallPreVC: UIViewController, RKCallListener {
    
    var cancelBtn: UIButton!
    
    var callVideoView: UIView!
    
    var callView = CallView()
    
    var userIds = [String]()
    
    // 标记是否在预发起阶段，需要返回
    var isMeetingPre: Bool = true
    var backCameraPre: Bool = false
    var meetingNamePre: String = ""
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
  
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if callVideoView.isHidden {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TempTool.forceOrientationLandscape()
        UIDevice.deviceNewOrientation(.landscape)
        // 背景视频return  UIInterfaceOrientationMaskPortrait;
        callVideoView = UIView.init()
        self.view.addSubview(callVideoView)
        callVideoView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        // 呼叫设置视图
        callView.delegate = self
        self.view.addSubview(callView)
        callView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        // 取消按钮
        cancelBtn = UIButton(type:.custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel!.font = RKFont.font_mainText
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.addTarget(self, action:#selector(popCallViewController), for: .touchUpInside)
        self.view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.left.equalTo(UI.SafeTopHeight)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        // 切换摄像头
        let switchCameraBtn = UIButton(type:.custom)
        let normalImage = UIImage(named: "media_setting_camera_switch")
        switchCameraBtn.setImage(normalImage, for: .normal)
        switchCameraBtn.addTarget(self, action:#selector(switchCameraBtnAction(_:)), for: .touchUpInside)
        self.view.addSubview(switchCameraBtn)
        switchCameraBtn.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.right.equalTo(-UI.SafeTopHeight - 20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
             
        let maxResolution = String(MeetingManager.shared.maxResolution.rawValue) + "P"
        callView.cloudRecordType = RKCloudRecordType(rawValue: maxResolution) ?? .middle
        
        MeetingManager.shared.backCamera = backCameraPre
        
        MeetingManager.shared.meetingName = meetingNamePre
        
        RKDevice.startCameraVideo(type: .RENDER_FULL_SCREEN, view: self.callVideoView)
        
        RKCooperationCore.shared.addCall(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        RKCooperationCore.shared.removeCall(listener: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        UIDevice.deviceNewOrientation(.landscape)
    }
    
    // MARK: - 进入房间
    fileprivate func enterRoomViewController() {
        
        let roomVC = MideaRoomVC.init()
        self.navigationController?.pushViewController(roomVC, animated: true)
        
    }

    @objc func popCallViewController() {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        MeetingManager.shared.leaveMeeting()
    }
    
    @objc func switchCameraBtnAction(_ sender: UIButton) {
        
        RKDevice.switchCamera()
        
        MeetingManager.shared.currentBackCamera = !MeetingManager.shared.currentBackCamera
        
    }
    
}


// MARK: - 呼叫设置回调
extension CallPreVC: CallViewDelegate {
    func cloudRecordBtnAction(_ sender: UIButton) {
        
    }
    
    
    func audioBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        MeetingManager.shared.audioSwitch = !MeetingManager.shared.audioSwitch
    }
    
    func videoBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        MeetingManager.shared.cameraSwitch = !MeetingManager.shared.cameraSwitch
        if sender.isSelected == true {
            callVideoView.isHidden = true
            RKDevice.closeCamera()
        } else {
            callVideoView.isHidden = false
            RKDevice.openCamera()
        }
    }
    
    func trumpetBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        MeetingManager.shared.trumpetSwitch = !MeetingManager.shared.trumpetSwitch
    }
    
    func cloudRecordType(_ cloudRecordType: RKCloudRecordType) {
        if cloudRecordType == .low {
            MeetingManager.shared.maxResolution = .RESOLUTION_360
        } else if cloudRecordType == .middle {
            MeetingManager.shared.maxResolution = .RESOLUTION_720
        } else if cloudRecordType == .high {
            MeetingManager.shared.maxResolution = .RESOLUTION_1080
        }
    }
    
    // MARK: - 点击呼叫按钮
    func startBtnAction(_ sender: UIButton) {
        
        let comp:(String?, String?) ->Void = { name, pws in
            var meetingName = ContactManager.shared.userInfo.realName
            if let name = name, !name.isEmpty{
                meetingName = name
            }
            MeetingManager.shared.createMeeting(meetingName: meetingName, password: nil, userIds: self.userIds, maxResolution: MeetingManager.shared.maxResolution, onSuccess: { data in
                self.startWaitingMeeting()
            }) { error in
                guard let error = error else { return }
                QMUITips.showError("\(error)")
            }
        }
        
        isMeetingPre = false
     
        let alertController = QMUIAlertController(title: "设置房间名和密码", message: nil, preferredStyle: .alert)
        alertController.addTextField { tf in
            tf.placeholder = "请输入房间名可为空"
        }
        alertController.addTextField { tf in
            tf.placeholder = "请输入密码可为空"
            tf.keyboardType = .asciiCapable
        }
        
        let doneAction = QMUIAlertAction(title: "确定", style: .default) { controll, action in
            let channalName = controll.textFields?[0].text
            let psw = controll.textFields?[1].text
            comp(channalName, psw)
        }

        alertController.addAction(doneAction)
        alertController.showWith(animated: true)

    }
    
    // MARK: - 呼叫等待页面
    fileprivate func startWaitingMeeting() {
        callView.isHidden = true
        joinMeeting()
        enterRoomViewController()
    }
    
    // MARK: - 加入会议配置
    fileprivate func joinMeeting() {
        
        guard let channel = MeetingManager.shared.channel else {
            return
        }
        
        // 会议开始 上报会议成员
        var userIds: [String] = []
        if let contact = ContactManager.shared.contactFrom(userId: ContactManager.shared.userInfo.userId) {
            userIds.append(contact.userId)
        } else if ContactManager.shared.userInfo.userId.count > 0 {
            userIds.append(ContactManager.shared.userInfo.userId)
        }
        // 加入频道 设置分辨率
        channel.channelParam.maxResolution = MeetingManager.shared.maxResolution
        
        var customProperty: [String: String] = [:]
        customProperty["meetingId"] = channel.channelId
        if let customPropertyJson = customProperty.jsonString() {
            channel.channelParam.extraParam = customPropertyJson
        }
        channel.channelParam.isVideo = MeetingManager.shared.cameraSwitch
        channel.channelParam.isAudio = MeetingManager.shared.audioSwitch
        MeetingManager.shared.channel?.join(param: nil)
    }
    
}

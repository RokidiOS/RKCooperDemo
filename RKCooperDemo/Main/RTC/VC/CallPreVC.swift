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

class CallPreVC: UIViewController {
    
    var cancelBtn: UIButton!
    
    var callVideoView: UIView!
    
    var callView = CallView()
    
    var userIds = [String]()
    
    // 标记是否在预发起阶段，需要返回
    var isMeetingPre: Bool = true
    var backCameraPre: Bool = false
    var meetingNamePre: String = ""
        
    var alertVC: QMUIAlertController?
    
    var channelParam = RKChannelParam()
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
    
    deinit {
        RKDevice.closeCamera()
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
        
        let configParambtn = UIButton(type:.custom)
        configParambtn.setTitle("参数配置", for: .normal)
        configParambtn.titleLabel!.font = RKFont.font_mainText
        configParambtn.setTitleColor(.white, for: .normal)
        configParambtn.addTarget(self, action:#selector(changeParam), for: .touchUpInside)
        self.view.addSubview(configParambtn)
        configParambtn.snp.makeConstraints { (make) in
            make.top.equalTo(cancelBtn.snp.bottom).offset(30)
            make.left.equalTo(UI.SafeTopHeight)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
                
        // 强制横屏控制
        let forceOrientationLabel = UILabel()
        forceOrientationLabel.font = UIFont.systemFont(ofSize: 14)
        forceOrientationLabel.textColor = .white
        forceOrientationLabel.text = "强制横屏"
        view.addSubview(forceOrientationLabel)
        forceOrientationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(configParambtn.snp.bottom).offset(20)
            make.left.equalTo(configParambtn.snp.left).offset(30)
            make.height.equalTo(30)
        }
        
        let forceOrientationSwitch = UISwitch()
        forceOrientationSwitch.isOn = true
        forceOrientationSwitch.addTarget(self, action: #selector(forceOrientation), for: .valueChanged)
        view.addSubview(forceOrientationSwitch)
        forceOrientationSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(forceOrientationLabel)
            make.left.equalTo(forceOrientationLabel.snp.right).offset(10)
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
        channelParam.maxResolution = .RESOLUTION_720
        MeetingManager.shared.audioSwitch = true
        MeetingManager.shared.cameraSwitch = true
        MeetingManager.shared.trumpetSwitch = true
        
        RKCooperationCore.shared.getChannelManager().addChannel(listener: self)
        
        RKCooperationCore.shared.getCallManager().addCallState(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        RKCooperationCore.shared.removeCall(listener: self)
        RKCooperationCore.shared.getChannelManager().removeChannel(listener: self)
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
    
    @objc func changeParam() {
        let configVC = ChannelConfigVC()
        configVC.param = channelParam
        configVC.okClick = {[weak self] param in
            self?.channelParam = param
        }
        self.navigationController?.pushViewController(configVC, animated: true)
        
    }
        
    @objc func forceOrientation(_ swi: UISwitch) {
        if swi.isOn {
            TempTool.forceOrientationLandscape()
            UIDevice.deviceNewOrientation(.landscape)
        } else {
            let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.rotation = .all
        }
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
        channelParam.maxResolution = MeetingManager.shared.maxResolution

    }
    
    // MARK: - 点击呼叫按钮
    func startBtnAction(_ sender: UIButton) {
        
        QMUITips.showLoading(in: self.view)
        MeetingManager.shared.createMeeting(meetingName: "", userIdLiset: userIds, channelParam: channelParam) { data in
            
            self.joinMeeting()
        } onFailed: { error in
            QMUITips.hideAllTips()
            guard let error = error else { return }
            QMUITips.showError("\(error)")
        }
        
    }
    
    // MARK: - 加入会议配置
    fileprivate func joinMeeting() {
        
        guard let channel = MeetingManager.shared.channel else {
            return
        }
        
        // 加入频道 设置分辨率
        
        var customProperty: [String: String] = [:]
        customProperty["meetingId"] = channel.channelId
        if let customPropertyJson = customProperty.jsonString() {
            channel.channelParam.extraParam = customPropertyJson
        }
        
        channelParam.isVideo = MeetingManager.shared.cameraSwitch
        channelParam.isAudio = MeetingManager.shared.audioSwitch
        
        MeetingManager.shared.channel?.join(param: channelParam, onSuccess: { data in
            QMUITips.hideAllTips()
        }, onFailed: { error in
            QMUITips.hideAllTips()
            QMUITips.showError("\(String(describing: error))")
        })
    }
    
}

extension CallPreVC: RKChannelListener {
    
    func onJoinChannelResult(channelId: String, result: Bool, reason: RKCooperationCode) {
        if result == true {
            let userIdList = userIds.filter { $0 != RKUserManager.shared.userId }
            /// 一对一呼叫等待接听
            guard userIdList.count == 1 else {
                enterRoomViewController()
                return
            }
            
            // 加入成功
            let alertVC = QMUIAlertController(title: "等待接听...", message: nil, preferredStyle: .alert)
            self.alertVC = alertVC
            let cancelAction = QMUIAlertAction(title: "取消呼叫", style: .default) { _, _ in
                RKCooperationCore.shared.getCallManager().cancel(channelId: channelId, userIdList: self.userIds) { data in
                    QMUITips.showInfo("取消成功")
                    self.popCallViewController()
                } onfailed: { error in
                    QMUITips.showInfo("取消失败 \(error?.localizedDescription)")
                }
            }
            //            let joinAction = QMUIAlertAction(title: "进入房间", style: .default) { _, _ in
            //                self.enterRoomViewController()
            //            }
            
            //            alertVC.addAction(joinAction)
            alertVC.addAction(cancelAction)
            alertVC.showWith(animated: true)
        }
    }
    
    func onUserScreenShareStateChanged(screenUserId: String?) {
        
    }
    
    func onLeave(channelId: String?, reason: RKCooperationCode) {
        
    }
    
    func onKicked(channelId: String?, byUserId: String) {
        
    }
    
    func onDispose() {
        
    }
    
    func onChannelStateChanged(newState: RKChannelState, oldState: RKChannelState) {
        
    }
    
    func onCustomPropertyChanged(customProperty: String?) {
        
    }
    
    func onRecordStateChanged(recordState: RKRecordState) {
        
    }
    
    func onUserJoinChannel(channelId: String, userId: String) {
        
    }
    
    func onUserLeaveChannel(channelId: String?, userId: String?) {
        
    }
    
    func onChannelShare(channelId: String?, shareType: RKShareType) {
        
    }
    
    func onUserRejoin(channelId: String?, userId: String?) {
        
    }
    
}

extension CallPreVC: RKCallListener {
    public func onCallAccept(channelId: String, userId: String) {
        let userIdList = userIds.filter { $0 != RKUserManager.shared.userId }
        /// 一对一呼叫等待接听
        guard userIdList.count == 1 else {
            return
        }
        alertVC?.hideWith(animated: true)
        QMUITips.showInfo("\(userId)已接听")
        enterRoomViewController()
    }
    
    public func onCallRejected(channelId: String, userId: String, inviteUserId: String) {
        let userIdList = userIds.filter { $0 != RKUserManager.shared.userId }
        /// 一对一呼叫等待接听
        guard userIdList.count == 1 else {
            return
        }
        alertVC?.hideWith(animated: true)
        QMUITips.showInfo("\(userId)已拒接")
        popCallViewController()
    }
    
    public func onCallBusy(channelId: String, userId: String, inviteUserId: String) {
        let userIdList = userIds.filter { $0 != RKUserManager.shared.userId }
        /// 一对一呼叫等待接听
        guard userIdList.count == 1 else {
            return
        }
        alertVC?.hideWith(animated: true)
        QMUITips.showInfo("\(userId)正忙")
        popCallViewController()
    }
    
}

//
//  MeetingRoomViewController.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/19.
//  会议主页

import UIKit
import RKIUtils
import RKILogger
import RKCooperationCore
import ARKit
import QMUIKit
import ReplayKit
import QMUIKit

class MideaRoomVC: UIViewController {
    // 房间成员表视图
    var roomMemberCollectionView: MeetingRoomCollectionView!
    // 通话设置功能控件
    var mediaSettingToolBar: MediaSettingToolBar!
    // 顶部导航视图
    var meetingRoomNavToolBar: MeetingRoomNavToolBar!
    // 录制控制按钮
    let recordBtn = UIButton()
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // 标记离开房间
    var isLeaveMeetingRoom = false
    // 标记是否请求了 SyncMeetingInfoRequest
    var isSyncMeetingInfoRequest: Bool = false
    
    fileprivate var meetingStartTime: Int64 = 0
    fileprivate weak var timer: Timer?
    // 是否是屏幕共享
    private var isScreenShareing = false
    
    ///全屏 视频视图
    var fullVideoView = FullVideoView()
    //    let uploadAtreamInfoLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetingRoomNavToolBar = MeetingRoomNavToolBar()
        meetingRoomNavToolBar.backgroundColor = RKColor.roomBarNavBgClr
        view.addSubview(meetingRoomNavToolBar)
        
        roomMemberCollectionView = MeetingRoomCollectionView()
        roomMemberCollectionView.delegate = self
        view.addSubview(roomMemberCollectionView)
        
        mediaSettingToolBar = MediaSettingToolBar()
        mediaSettingToolBar.delegate = self
        mediaSettingToolBar.settingButtons = [.shutDown, .audio, .trumpet, .video, .invite, .tools]
        view.addSubview(mediaSettingToolBar)
        
        meetingRoomNavToolBar.roomNameLabel.text = ""
        meetingRoomNavToolBar.roomTimeLabel.text = "00:00"
        
        meetingRoomNavToolBar.snp.makeConstraints { (make) in
            make.left.width.equalTo(roomMemberCollectionView)
            make.top.equalTo(0)
            make.height.equalTo(40)
        }
        
        roomMemberCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(meetingRoomNavToolBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.rightMargin.equalTo(0)
            make.leftMargin.equalTo(0)
        }
        
        mediaSettingToolBar.snp.makeConstraints { (make) in
            make.top.height.equalToSuperview()
            make.width.equalTo(71 + UI.SafeTopHeight)
            make.right.equalTo(0)
        }
        
        // 创建、加入会议
        joinMeeting()
        // 记录自己的开始时间
        meetingStartTime = Int64(Date().timeIntervalSince1970)
        // 更新房间名字
        updateRoomName()
        
        // 添加频道监听
        RKCooperationCore.shared.getCallManager().addCallState(listener: self)
        MeetingManager.shared.channel?.addChannel(listener: self)
        MeetingManager.shared.channel?.addRemoteDevice(listener: self)
        MeetingManager.shared.channel?.addShare(listener: self)
        RKMessageCenter.addChannelMsg(listener: self, channelId: MeetingManager.shared.channel?.channelId ?? "")
        MeetingManager.shared.channel?.addDevice(listener: self)
        MeetingManager.shared.channel?.addRemoteDevice(listener: self)
        view.addSubview(fullVideoView)
        
        view.addSubview(recordBtn)
        recordBtn.setTitle("录制设置", for: .normal)
        recordBtn.backgroundColor = .black
        recordBtn.titleLabel?.font = .systemFont(ofSize: 12)
        recordBtn.snp.makeConstraints { make in
            make.left.top.equalTo(meetingRoomNavToolBar)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        recordBtn.setTitleColor(.white, for: .normal)
        recordBtn.addTarget(self, action: #selector(showRecordFunctionMenu), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        isLeaveMeetingRoom = false
        
        updateMeetingPartp()
        
        refreshSwitchUI()
        
        startTimer()
        
        TempTool.forceOrientationLandscape()
        // 设置屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        isLeaveMeetingRoom = true
        
        stopTimer()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    // MARK: - 加入会议
    func joinMeeting() {
        
        guard let channel = MeetingManager.shared.channel else {
            return
        }
        
        if channel.channelName.isEmpty == false {
            meetingRoomNavToolBar.roomNameLabel.text = channel.channelName
        } else {
            meetingRoomNavToolBar.roomNameLabel.text = channel.channelId
        }
        
        // 查询频道内是否有人在屏幕共享
        //        RKCooperationCore.shared.getShareScreenManager().shareScreenUserId(channelId: channel.channelId) { userIds in
        //            if userIds?.contains(RKUserManager.shared.userId) == true {
        //                self.isScreenShareing = true
        //            }
        //        }
    }
    
    // MARK: - 更新房间成员状态
    @objc func updateMeetingPartp() {
        
        updateRoomName()
        
        guard isLeaveMeetingRoom == false else {
            return
        }
        
        guard let parts = MeetingManager.shared.channel?.participants,
              parts.isEmpty == false else {
            return
        }
        
        var partsUserIds: [String] = []
        parts.forEach { part in
            partsUserIds.append(part.userId)
            if let member = roomMemberCollectionView.meetingMembers.first(where: { $0.userId == part.userId }) {
                member.participant = part
                member.state = nil
                if part.userId == RKUserManager.shared.userId, isScreenShareing == true {
                    member.state = "屏幕共享中"
                } else {
                    member.state = nil
                }
            } else {
                let member = RKRoomMember()
                member.userId = part.userId
                member.userName = part.displayName ?? ""
                member.participant = part
                roomMemberCollectionView.meetingMembers.append(member)
                if part.userId == RKUserManager.shared.userId, isScreenShareing == true {
                    member.state = "屏幕共享中"
                } else {
                    member.state = nil
                }
            }
            
        }
        
        updateRoomName()
        self.roomMemberCollectionView.collectionView.reloadData()
        
    }
    
    // MARK: - 更新会议房间名字
    func updateRoomName() {
        
        
    }
    
    func refreshSwitchUI() {
        
        mediaSettingToolBar.audioButton.isSelected = !MeetingManager.shared.audioSwitch
        mediaSettingToolBar.trumpetButton.isSelected = !MeetingManager.shared.trumpetSwitch
        mediaSettingToolBar.videoButton.isSelected = !MeetingManager.shared.cameraSwitch
        
        DispatchQueue.global(qos: .default).async {
            MeetingManager.shared.channel?.enableUploadLocalAudioStream(enable: MeetingManager.shared.audioSwitch)
            MeetingManager.shared.channel?.enableUploadLocalVideoStream(enable: MeetingManager.shared.cameraSwitch)
            RKDevice.enableSpeaker(MeetingManager.shared.trumpetSwitch)
        }
        
    }
    
    // MARK: - 弹Alert
    func showSubMenu(type: AlertViewType) {
        let alertView = CallAlertView()
        alertView.delegate = self
        alertView.showContentView(type: type)
        self.view.addSubview(alertView)
        alertView.snp.makeConstraints { (make) in
            make.top.left.width.height.equalToSuperview()
        }
    }
    
    /// 检查霸屏功能
    func refreshMeetingStatus(_ showToast: Bool = true, _ showDetail: Bool = true) {
        
    }
    
    
    func startTimer() {
        
        guard self.timer == nil else {
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerProc), userInfo: nil, repeats: true)
        self.timer?.fire()
        
    }
    
    func stopTimer() {
        
        guard self.timer != nil else {
            return
        }
        
        if self.timer!.isValid {
            self.timer!.invalidate()
            self.timer = nil
        }
        
    }
    
    @objc func timerProc() {
        
        let timeNow = Int64(Date().timeIntervalSince1970)
        let timeInterval = timeNow - meetingStartTime
        meetingRoomNavToolBar.roomTimeLabel.text = String.formatTalkingTime(timeInterval)
    }
    
    @objc func showRecordFunctionMenu() {
        
        guard let channelId = MeetingManager.shared.channel?.channelId else { return }
        
        let alertVC = QMUIAlertController(title: "录制设置", message: nil, preferredStyle: .actionSheet)
        let beginAction = QMUIAlertAction(title: "开始录制", style: .default) { _, _ in
            self.beginRecord(channelId)
        }
        let cancelAction = QMUIAlertAction(title: "关闭录制", style: .default) { _, _ in
            RKCooperationCore.shared.getChannelManager().stopServerRecording(channelId: channelId, save: true)
        }
        let bitAndDelayAction = QMUIAlertAction(title: "设置码率、延迟", style: .default) { _, _ in
            self.showBitAndDelayAlert()
        }
        
        alertVC.addAction(beginAction)
        alertVC.addAction(cancelAction)
        alertVC.addAction(bitAndDelayAction)
        alertVC.showWith(animated: true)
    }
    
    private func beginRecord(_ channelId: String) {
        let recordBlock = { (isHight: Bool) in
            RKCooperationCore.shared.getChannelManager().startServerRecording(channelId: channelId, bucket: "RokidiOS", fileName: String.uuid(), resolution: .RESOLUTION_720, subStream: isHight ? .high : .low) { _ in

            } onFailed: { error in
                QMUITips.showSucceed("开启录制失败\(String(describing: error))")
            }
        }

        let alertVC = QMUIAlertController(title: "录制设置", message: nil, preferredStyle: .alert)
        let recordHight = QMUIAlertAction(title: "录制大流", style: .default) { _, _ in
            recordBlock(true)
        }
        let recordLow = QMUIAlertAction(title: "录制小流", style: .default) { aler, _ in
            recordBlock(false)
        }

        alertVC.addAction(recordHight)
        alertVC.addAction(recordLow)
        
        alertVC.showWith(animated: true)
        
    }
    
    private func showBitAndDelayAlert() {
        let alertVC = QMUIAlertController(title: "设置码率和延迟", message: nil, preferredStyle: .alert)
        alertVC.addTextField { tf in
            tf.placeholder = "设置最大码率 kbps"
            tf.maximumTextLength = 7
            tf.keyboardType = .numberPad
        }
        alertVC.addTextField { tf in
            tf.placeholder = "设置最大延迟 ms"
            tf.maximumTextLength = 7
            tf.keyboardType = .numberPad
        }
        let cancelAction = QMUIAlertAction(title: "取消", style: .default) { _, _ in
            
        }
        let bitAndDelayAction = QMUIAlertAction(title: "确定", style: .default) { aler, _ in
            guard let btText = aler.textFields![0].text, !btText.isEmpty else {
                QMUITips.showError("码率不能为空哦")
                return
            }
            guard let delayText = aler.textFields![1].text, !delayText.isEmpty else {
                QMUITips.showError("延迟不能为空哦")
                return
            }
            guard let btInt = Int32(btText), let delayInt = Int32(delayText) else {
                QMUITips.showError("参数不合法")
                return
            }
            if let channel = MeetingManager.shared.channel {
                RKShareManager.shared.clearShare(channelId: channel.channelId)
                channel.configVideoQuality(maxPublishBitrate: btInt, maxDelay: delayInt)
            }
        }

        alertVC.addAction(bitAndDelayAction)
        alertVC.addAction(cancelAction)
        
        alertVC.showWith(animated: true)
    }
}

// MARK: 呼叫监听
extension MideaRoomVC: RKCallListener {
    
    func onCallAccept(channelId: String, userId: String) {
        
        if let contact = ContactManager.shared.contactFrom(userId: userId) {
            QMUITips.showInfo("\(contact.realName)已接听", in: self.view)
        }
        
        updateMeetingPartp()
        
    }
    
    func onCallBusy(channelId: String, userId: String) {
        
        if let contact = ContactManager.shared.contactFrom(userId: userId) {
            QMUITips.showInfo("\(contact.realName)正忙，请稍后重试", in: self.view)
        } else {
            QMUITips.showInfo("对方正忙，请稍后重试", in: self.view)
        }
        
    }
    
    func onCallRejected(channelId: String, userId: String) {
        
        if let contact = ContactManager.shared.contactFrom(userId: userId) {
            QMUITips.showInfo("\(contact.realName)拒绝了你的协作请求", in: self.view)
        } else {
            QMUITips.showInfo("对方拒绝了你的协作请求", in: self.view)
        }
        
    }
    
}

// MARK: 频道消息监听
extension MideaRoomVC: RKChannelListener {
    
    func onDispose() {
        QMUITips.show(withText: "频道关闭！")
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        // 自己是分享主角 需要关闭share事件
        if let channel = MeetingManager.shared.channel {
            RKShareManager.shared.clearShare(channelId: channel.channelId)
        }
        
        MeetingManager.shared.leaveMeeting()
    }
    
    func onJoinChannelResult(channelId: String, result: Bool, reason: RKCooperationCode) {
        
        updateMeetingPartp()
        
    }
    
    func onUserScreenShareStateChanged(screenUserId: String?) {
        
        updateMeetingPartp()
    }
    
    func onLeave(channelId: String?, reason: RKCooperationCode) {
        updateMeetingPartp()
    }
    
    func onChannelStateChanged(newState: RKChannelState, oldState: RKChannelState) {
        
        updateMeetingPartp()
        
    }
    
    func onCustomPropertyChanged(customProperty: String?) {
        
        updateMeetingPartp()
        
    }
    
    func onRecordStateChanged(recordState: RKRecordState) {
        
    }
    
    func onUserJoinChannel(channelId: String, userId: String) {
        
        if let contactInfo = ContactManager.shared.contactFrom(userId: userId) {
            QMUITips.showInfo(contactInfo.realName + "已加入", in: self.view)
        }
        
        updateMeetingPartp()
    }
    
    func onUserLeaveChannel(channelId: String?, userId: String?) {
        
        guard let userId = userId,
              let contact = ContactManager.shared.contactFrom(userId: userId) else {
            return
        }
        // 移除离开的成员
        roomMemberCollectionView.meetingMembers.removeAll(where: { $0.userId == userId })
        
        if let shareInfo = MeetingManager.shared.channel?.shareInfo {
            if shareInfo.executorUserId == contact.userId {
                MeetingManager.shared.channel?.shareInfo = nil
                // 霸屏功能者离开了会议，返回房间
                self.navigationController?.popToViewController(self, animated: false)
            }
        }
        
        QMUITips.showInfo(contact.realName + "离开了会议")
        
        updateMeetingPartp()
        
    }
    
    func onUserKicked(channelId: String?, userIds: [String]) {
        
        userIds.forEach { userId in
            if let contact = ContactManager.shared.contactFrom(userId: userId) {
                // 移除被踢出的成员
                roomMemberCollectionView.meetingMembers.removeAll(where: { $0.userId == userId })
                
                if let shareInfo = MeetingManager.shared.channel?.shareInfo {
                    if shareInfo.executorUserId == contact.userId {
                        MeetingManager.shared.channel?.shareInfo = nil
                        // 霸屏功能者离开了会议，返回房间
                        self.navigationController?.popToViewController(self, animated: false)
                    }
                }
                
                QMUITips.showInfo(contact.realName + "被踢出了会议")
            }
        }
        
        updateMeetingPartp()
    }
    
    func onKicked(channelId: String?, byUserId: String) {
        // 自己是分享主角 需要关闭share事件
        if let channel = MeetingManager.shared.channel {
            RKShareManager.shared.clearShare(channelId: channel.channelId)
        }
        MeetingManager.shared.leaveMeeting()
    }
    
    func onChannelShare(channelId: String?, shareType: RKShareType) {
        
    }
    
    func onRecordingSwitch(_ isOpen: Bool) {
        if isOpen {
            QMUITips.show(withText: "录制已打开")
        } else {
            QMUITips.show(withText: "录制已关闭")
        }
    }
    
    func onRecordingStateChanged(_ recordingStateData: RKIRecordingStateModel) {
        if recordingStateData.recordingState == .recording {
            QMUITips.show(withText: "文件录制中...")
        } else if recordingStateData.recordingState == .uploading {
            QMUITips.show(withText: "录制文件上传中...")
        } else if recordingStateData.recordingState == .done {
            QMUITips.showSucceed("录制已完成 :\(recordingStateData.url ?? "")",
                                 detailText: "\(recordingStateData.startTime ?? "") | \(recordingStateData.endTime ?? "")")
        } else if recordingStateData.recordingState == .error {
            QMUITips.showError(recordingStateData.message)
        }
    }
    
    
}

// MARK: 远端设备信息改变监听
extension MideaRoomVC: RKRemoteDeviceListener {
    
    
    func onUserUploadAudioChanged(userId: String, enabled: Bool) {
        
        if userId == RKUserManager.shared.userId {
            MeetingManager.shared.audioSwitch = enabled
            refreshSwitchUI()
        }
        updateMeetingPartp()
        
    }
    
    func onUserUploadVideoChanged(userId: String, enabled: Bool) {
        
        updateMeetingPartp()
        
    }
    
    func onUserNetStatusChanged(userId: String, netStatus: RKNetStatus) {
        
        updateMeetingPartp()
        
    }
    
    func onUserVideoSizeChanged(userId: String, videoSize: RKVideoSize) {
        
        updateMeetingPartp()
        
    }
    
    func onUserVolumeChange(userId: String, status: RKVolumeStatus) {
        
        updateMeetingPartp()
        
        
    }
    
    func onShareError(code: RKShareErrorCode) {
        if code == .EXIST_SHARE {
            QMUITips.showError("频道内已经有人在共享了！")
        }
    }
    
    func onRemoteVideoStatus(_ userId: String,
                             rid: String?,
                             width: Int32,
                             height: Int32,
                             fps: Int32,
                             bitrate: Int32,
                             packetsLost: Int32) {
        DispatchQueue.main.async {
            let rid = rid ?? ""
            let qu = ""
            let newSting = self.roomMemberCollectionView.updateCell(userId: userId, width: width, height: height, fps: fps, rid: rid, bitrate: bitrate, qualityLimitationReason: qu, packetsLost: packetsLost)
            self.fullVideoView.showInfo(newSting)
        }
    }
    
    func onVideoStreamUnstable(userId: String, lossRate: Float) {
        DispatchQueue.main.async {
            self.roomMemberCollectionView.updateCell(userId: userId, lossRate: lossRate)
        }
    }
    
}

// MARK:  共享消息监听
extension MideaRoomVC: RKShareListener {
    
    func onStartShareScreen(userId: String) {
        
        refreshMeetingStatus()
        
    }
    
    func onStopShareScreen(userId: String) {
        
        onShareStop()
        
    }
    
    func onStartShareDoodle(userId: String) {
        
        guard let channel = MeetingManager.shared.channel else {
            return
        }
        
        // 进入白板view
        RKCooperationCore.shared.getShareDoodleManager().joinShareDoodle(channelId: channel.channelId)
        pushToDoodleVC()
    }
    
    func onStopShareDoodle(userId: String) {
        
        if let channel = MeetingManager.shared.channel {
            RKShareDoodleManager.shared.clear(channelId: channel.channelId)
        }
        
        onShareStop()
        
    }
    
    func onStartShareImageDoodle(userId: String, imgUrl: String) {
        
        guard let channel = MeetingManager.shared.channel else {
            return
        }
        
        // 进入截图
        RKCooperationCore.shared.getShareDoodleManager().joinShareDoodle(channelId: channel.channelId, doodleImageUrl: imgUrl)
        pushToDoodleVC()
    }
    
    func onStopShareImageDoodle(userId: String) {
        
        if let channel = MeetingManager.shared.channel {
            RKShareDoodleManager.shared.clear(channelId: channel.channelId)
        }
        
        onShareStop()
        
    }
    
    func onStartShareSlam(userId: String, executorUserId: String) {
        
        refreshMeetingStatus()
        
    }
    
    func onStopShareSlam(userId: String) {
        
        if let shareInfo = MeetingManager.shared.channel?.shareInfo,
           shareInfo.executorUserId == ContactManager.shared.userInfo.userId {
            RKDevice.stopVideoFile()
            // 需要打开摄像头
            RKDevice.openCamera()
            // 默认会开启前置，是否需要切换到后置
            if MeetingManager.shared.currentBackCamera == true {
                RKDevice.switchCamera()
            }
            
        }
        
        onShareStop()
    }
    
    func onStartSharePointVideo(userId: String, executorUserId: String) {
        
        refreshMeetingStatus()
        
    }
    
    func onStopSharePointVideo(userId: String) {
        
        onShareStop()
        
    }
    
    func onShareStop() {
        
        roomMemberCollectionView.meetingMembers.forEach { meetingMember in
            
        }
        
        roomMemberCollectionView.collectionView.reloadData()
        
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    /// 视频点选
    func onPointVideo(message: RKPointVideoMessage) {
        
        guard let channel = MeetingManager.shared.channel else {
            return
        }
        if message.actionType == .req {
            RKSharePointManager.shared.establishRespond(channelId: channel.channelId,
                                                        userId: message.userId)
        }
    }
    
    /// 视频控制
    func onVideoControl(message: RKVideoControlMessage) {
        
        
    }
    
}

// MARK: - 房间回调
extension MideaRoomVC: MeetingRoomCollectionViewDelegate {
    
    func didSelectItemAt(_ memberView: RKRoomMember, cell: MeetingRoomCollectionCell) {
        let alertSheet = RKAlertController.alertSheet(title: "功能菜单").add(title: "查看详情", style: .default) {
            self.showFullVideo(memberView.userId, cell: cell)
        }
        if memberView.userId == RKUserManager.shared.userId {
            alertSheet.add(title: "分辨率设置", style: .default) {
                self.changeResolution()
            }
        }
        
        let alertVC = alertSheet.add(title: "取消", style: .cancel) {}.finish()
        
        present(alertVC, animated: true, completion: nil)
        
    }
    
    private func showFullVideo(_ userId: String, cell: MeetingRoomCollectionCell) {
        // 切换大流
        if userId != RKUserManager.shared.userId {
            MeetingManager.shared.channel?.switchStream(userId: userId, isHighStram: true)
        }
        
        fullVideoView.userId = userId
        fullVideoView.delegate = self
        fullVideoView.frame = cell.frame
        fullVideoView.isHidden = false
        fullVideoView.lastVieoView = cell.videoView
        fullVideoView.lastVideoSuperView = cell.contentView
        cell.videoView.removeFromSuperview()
        fullVideoView.addSubview(cell.videoView)
        cell.videoView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        fullVideoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 本端分辨率设置
    fileprivate func changeResolution() {
        let placeholderAndTexts = [("width", "1280"), ("height", "720"), ("fps", "30")]
        let alertVC = RKAlertController.alertInputViews(title: "请输入分辨率参数",
                                                        message: nil,
                                                        placeholderAndTexts: placeholderAndTexts) { text in
            guard let width = Int32(text[0]),
                  let height = Int32(text[1]),
                  let fps = Int32(text[2]) else {
                return
            }
            
            RKDevice.setCameraProperty(width: width, height: height, framerate: fps)
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func startRecord() {
        guard let channel = MeetingManager.shared.channel else { return }
        if isScreenShareing  {
            RKCooperationCore.shared.getShareScreenManager().stopShareScreen(channelId: channel.channelId)
            isScreenShareing = false
        } else {
            RKCooperationCore.shared.getShareScreenManager().startShareScreen(channelId: channel.channelId)
            isScreenShareing = true
        }
        QMUITips.showSucceed(isScreenShareing ? "开启屏幕共享成功" : "关闭屏幕共享成功")
        
        updateMeetingPartp()
    }
    
    private func pushToDoodleVC() {
        guard let channel = MeetingManager.shared.channel else { return }
        let doodleVC = DoodleVC()
        doodleVC.channelId = channel.channelId
        navigationController?.pushViewController(doodleVC, animated: true)
    }
}

extension MideaRoomVC: FullVideoViewDelegate {
    
    func fullVideoViewDidHidden(_ userId: String) {
        // 切换小流
        if userId != RKUserManager.shared.userId {
            MeetingManager.shared.channel?.switchStream(userId: userId, isHighStram: false)
        }
    }
    
    func screenSnapshot(_ userId: String) {
        guard let parts = MeetingManager.shared.channel?.participants,
              parts.isEmpty == false else {
            return
        }
        let part = parts.first { part in
            return part.userId == userId
        }
        let name = "\(String.uuid()).jpg"
        if let image = part?.videoCanvas?.snapshot(width: -1, height: -1, filePath: RKFileUtil.fileDir().appendingPath(path: name)) {
            QMUIAssetsManager.sharedInstance().saveImage(withImageRef: image.cgImage, albumAssetsGroup: nil, orientation: .right) {asset, error in
                if let error = error {
                    QMUITips.showError("\(error)")
                } else {
                    QMUITips.showSucceed("保存相册成功")
                }
            }
        }
        
        
    }
}

// MARK: - 功能设置按钮回调
extension MideaRoomVC: MediaSettingToolBarDelegate {
    
    func settingToolBtnAction(_ settingBtnAction: SettingButtonAction) {
        switch settingBtnAction {
        case .shutDown, .pop:
            
            CustomAlertView().showAlertView(self.view ,"是否退出会议？", "", "取消", "确定") {
                
            } _: {
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                
                // 自己是分享主角 需要关闭share事件
                if let channel = MeetingManager.shared.channel
                {
                    RKShareManager.shared.clearShare(channelId: channel.channelId)
                }
                MeetingManager.shared.leaveMeeting()
            }
        case .audio:
            MeetingManager.shared.audioSwitch = !MeetingManager.shared.audioSwitch
            refreshSwitchUI()
            if MeetingManager.shared.audioSwitch == true {
                MeetingSwitchToast.show(SwitchType.audioOn, inView: self.view)
            } else {
                MeetingSwitchToast.show(SwitchType.audioOff, inView: self.view)
            }
        case .trumpet:
            MeetingManager.shared.trumpetSwitch = !MeetingManager.shared.trumpetSwitch
            refreshSwitchUI()
            if MeetingManager.shared.trumpetSwitch == true {
                MeetingSwitchToast.show(SwitchType.trumpetOn, inView: self.view)
            } else {
                MeetingSwitchToast.show(SwitchType.trumpetOff, inView: self.view)
            }
        case .video:
            showSubMenu(type: .camera)
        case .invite:
            showSubMenu(type: .member)
        case .tools:
            showSubMenu(type: .tools)
        default: break
            
        }
    }
    
    func settingToolHiddenBtnAction(_ button: UIButton) {
        
    }
    
}
// MARK: - 工具箱回调
extension MideaRoomVC: AlertViewDelegate {
    func alertViewAction(_ action: AlertViewActionType) {
        switch action {
        case .camera_switch:
            RKDevice.switchCamera()
            MeetingManager.shared.currentBackCamera = !MeetingManager.shared.currentBackCamera
            MeetingSwitchToast.show(.cameraSwitch, inView: self.view)
        case .camera_on_off:
            MeetingManager.shared.cameraSwitch = !MeetingManager.shared.cameraSwitch
            refreshSwitchUI()
            updateMeetingPartp()
            if MeetingManager.shared.cameraSwitch == true {
                MeetingSwitchToast.show(SwitchType.cameraOn, inView: self.view)
            } else {
                MeetingSwitchToast.show(SwitchType.cameraOff, inView: self.view)
            }
        case .member_invite:
            let inviteVC = ContactListVC()
            inviteVC.title = "邀请成员"
            inviteVC.invited = true
            self.navigationController?.pushViewController(inviteVC, animated: true)
            
            break
        case .member_audio_off: // 全员静音
            MeetingManager.shared.channel?.muteAll()
            MeetingSwitchToast.show(.muteOn, inView: self.view)
        case .tool_share:
            startRecord()
        case .tool_doodle:
            guard let channel = MeetingManager.shared.channel else {
                return
            }
            RKCooperationCore.shared.getShareDoodleManager().startShareDoodle(channelId: channel.channelId)
        default:
            break
        }
    }
}

// MARK: - 霸屏功能
extension MideaRoomVC {
    
    func enterMideaDetail(member: RKRoomMember) {
        
    }
}

// MARK: - 兼容消息
extension MideaRoomVC: RKChannelMsgListener {
    
    func onChannelMsgReceive(fromUserId: String, content: String) {
        
    }
}


// MARK: - 设备信息状态监听
extension MideaRoomVC : RKDeviceListener {
    
    
    // 本端视频参数回调
    func onVideoPublishStatus(rid: String?,
                              width: Int32,
                              height: Int32,
                              fps: Int32,
                              bitrate: Int32,
                              qualityLimitationReason: String?) {
        DispatchQueue.main.async {
            let rid = rid ?? ""
            let qu = qualityLimitationReason ?? ""
            let userId = ContactManager.shared.userInfo.userId
            let newString = self.roomMemberCollectionView.updateCell(userId: userId, width: width, height: height, fps: fps, rid: rid, bitrate: bitrate, qualityLimitationReason: qu)
            if self.fullVideoView.userId == userId {
                self.fullVideoView.showInfo(newString)
            }
            
        }
    }
    
    
    
    func onCameraUpdate() {
        
    }
    
    func onAudioOutputTypeChange(audioType: RKAudioOutputType) {
        
    }
    
    func onNeedKeyFrame() {
        
    }
    
    func onAudioOutputStateChanged(audioOutput: Bool) {
        
    }
    
    func onUploadVideoStateChanged(uploadLocalVideo: Bool) {
        
    }
    
    func onUploadAudioStateChanged(uploadLocalAudio: Bool) {
        
    }
    
    
}

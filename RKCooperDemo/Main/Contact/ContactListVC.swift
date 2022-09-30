//
//  ContactListVC.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//  联系人列表

import UIKit
import RKCooperationCore
import RKIHandyJSON
import QMUIKit

var kcontactList = [String]()

class ContactListVC: UITableViewController {
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var choosedList = [String]()
    ///当前是否是邀请
    var invited = false
    
    fileprivate var alertVC: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "联系人列表"
        loadData()
        
        RKCooperationCore.shared.addIncomingCall(listener: self)
    }
    /// 获取联系人列表
    @objc public func loadData() {
        DemoApiHelper.getUserList(companyIndex: DemoApiHelper.companyIndex) { responsed in
            if responsed.code == 1 {
                if var contactsList = responsed.data as? [String] {
                    if let lastLoginUserName = UserDefaults.standard.value(forKey: RKLoginUDKeys.userNameKey) as? String {
                        contactsList.removeAll { model in
                            if model == lastLoginUserName {
                                return true
                            } else{
                                return false
                            }
                        }
                    }
                    kcontactList = contactsList
                    ContactManager.shared.contactsListInfo = contactsList
                    self.tableView.reloadData()
                }
            }
        }

    }
    // 当时是否在视图最前面，是是否进行自动刷新的标志
    private var hasShow = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        configRightItem()
        hasShow = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TempTool.forceOrientationPortrait()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasShow = false
    }
        
    private func configRightItem() {
        if invited {
            let rightItem = UIBarButtonItem(title: "邀请", style: .done, target: self, action: #selector(invitedAction))
            navigationItem.rightBarButtonItem = rightItem
            navigationItem.hidesBackButton = false
        } else {
            let createItem = UIBarButtonItem(title: "  发起", style: .done, target: self, action: #selector(preCallMeeting))
            let joinItem = UIBarButtonItem(title: "加入  ", style: .done, target: self, action: #selector(joinMeeting))
            navigationItem.rightBarButtonItems = [createItem, joinItem]
            navigationItem.hidesBackButton = true
            
            let leftItem = UIBarButtonItem(title: "退出", style: .done, target: self, action: #selector(logouAction))
            navigationItem.leftBarButtonItem = leftItem
            navigationItem.hidesBackButton = true
        }
    }
    
    // 发起会议 前置页面
    @objc private func preCallMeeting() {
        MeetingManager.shared.startMeeting(userIds: choosedList, self)
    }
    
    // 主动加入会议
    @objc private func joinMeeting() {
        let placeholderAndTexts = [("频道ID(必须)", ""), ("密码(非必须)", "")]
        let alertVC = RKAlertController.alertInputViews(title: "请输入要加入的房间号和密码",
                                                        message: nil,
                                                        placeholderAndTexts: placeholderAndTexts) { text in
            guard let channelId = text.first, channelId.isEmpty == false,
                  let password = text.last else {
                QMUITips.showSucceed("频道ID不能为空！")
                return
            }
            
            // 加入已知频道
            RKChannelManager.shared.join(channelId: channelId, channelPassword: password) { data in
                guard let channel = RKChannelManager.shared.getChannel(channelId: channelId) else {
                    return
                }
                
                MeetingManager.shared.channel = channel
                // 主动加入监听 加入状态回调
                RKCooperationCore.shared.getChannelManager().addChannel(listener: self)
                
                // 进入房间
                let meetVC = MideaRoomVC()
                MeetingManager.shared.lastBeforeMeetingVC = self
                self.navigationController?.pushViewController(meetVC, animated: true)
                
            } onFailed: { error in
                QMUITips.showSucceed(error?.localizedDescription)
            }
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func invitedAction() {
        
        var userIds: [String] = []
        choosedList.forEach { model in
            userIds.append(model)
        }
        
        MeetingManager.shared.inviteMeeting(userIds)
        QMUITips.showSucceed("已邀请选中用户")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func logouAction() {
        
        RKCooperationCore.shared.logout()
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContactListVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kcontactList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ide = "cell"
        let model = kcontactList[indexPath.row]
        tableView.register(ContactCell.classForCoder(), forCellReuseIdentifier: ide)
        let cell = tableView.dequeueReusableCell(withIdentifier: ide, for: indexPath)
        if let cell = cell as? ContactCell {
            cell.model = model
            cell.showChoosed = choosedList.contains(where: { pModel in
                return pModel == model
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = kcontactList[indexPath.row]
        
        if choosedList.contains(where: { pModel in
            return pModel == model
        }) {
            choosedList.removeAll { pModel in
                return pModel == model
            }
        } else {
            choosedList.append(model)
        }
        print(choosedList)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}

// MARK: - 收到来电监听
extension ContactListVC: RKIncomingCallListener {
    
    func onReceiveCall(channelId: String, fromUserId: String, createTime: Int64, channelTitle: String, channelParam: RKChannelParam?) {
        let alertVC = UIAlertController(title: "收到邀请", message: "channelId： \(channelId)\n userId: \(fromUserId)", preferredStyle: .alert)
        self.alertVC = alertVC
        let silenceJoinAction = UIAlertAction(title: "静默接听", style: .default) { _ in
            MeetingManager.shared.audioSwitch = false
            MeetingManager.shared.cameraSwitch = false
            // 加入并接受
            MeetingManager.shared.accept(meetingId: channelId, self)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        
        let audioJoinAction = UIAlertAction(title: "语音接听", style: .default) { _ in
            MeetingManager.shared.cameraSwitch = false
            // 加入并接受
            MeetingManager.shared.accept(meetingId: channelId, self)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        
        let videoJoinAction = UIAlertAction(title: "视频接听", style: .default) { _ in
            MeetingManager.shared.audioSwitch = false
            // 加入并接受
            MeetingManager.shared.accept(meetingId: channelId, self)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }

        let joinAction = UIAlertAction(title: "音视频接听", style: .default) { _ in
            // 加入并接受
            MeetingManager.shared.accept(meetingId: channelId, self)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        let busyAction = UIAlertAction(title: "正忙", style: .default) { _ in
            // 当前正在会议中，处理约等于拒接
            RKCooperationCore.shared.getCallManager().busy(channelId: channelId, onSuccess: nil, onfailed: nil)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        let rejectAction = UIAlertAction(title: "拒接", style: .default) { _ in
            // 拒接
            RKCooperationCore.shared.getCallManager().reject(channelId: channelId, onSuccess: nil, onfailed: nil)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
        
        alertVC.addAction(silenceJoinAction)
        alertVC.addAction(audioJoinAction)
        alertVC.addAction(videoJoinAction)
        alertVC.addAction(joinAction)
        alertVC.addAction(busyAction)
        alertVC.addAction(rejectAction)
        present(alertVC, animated: true)
    }
    
    func onCallCanceled(channelId: String, userId: String) {
        QMUITips.showInfo("\(userId) 已取消呼叫 | channelId: \(channelId)")
        alertVC?.dismiss(animated: true)
    }
    
    @objc private func hidenJointAlert(_ alertVC: QMUIAlertController) {
        alertVC.dismiss(animated: true) {
            QMUITips.showError("邀请已经超时")
        }
        
    }
}

// MARK: - 频道监听
extension ContactListVC: RKChannelListener {
    
    func onDispose() {
        
    }
    
    func onJoinChannelResult(channelId: String, result: Bool, reason: RKCooperationCode) {
        if result == true {
            //            MeetingManager.shared.joinMeeting(meetingId: channelId, self)
        } else {
            QMUITips.showError("加入房间失败！")
        }
        // 移除监听回调
        RKCooperationCore.shared.getChannelManager().removeChannel(listener: self)
    }
    
    func onUserScreenShareStateChanged(screenUserId: String?) {
        
    }
    
    func onLeave(channelId: String?, reason: RKCooperationCode) {
        
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
    
    func onKicked(channelId: String?, byUserId: String) {
        
    }
    
    func onChannelShare(channelId: String?, shareType: RKShareType) {
        
    }
    
    func onUserRejoin(channelId: String?, userId: String?) {
        
    }
}

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

var kcontactList = [ContactModel]()

class ContactListVC: UITableViewController {
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var choosedList = [ContactModel]()
    ///当前是否是邀请
    var invited = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "联系人列表"
        loadData()
        setupTimer()
        RKCooperationCore.shared.addIncomingCall(listener: self)
    }
    /// 获取联系人列表
    @objc public func loadData() {
        RKAPIManager.shared.contactsList(keyword: nil) { data in
            if let dataDict = data as? [String: Any], let data = dataDict["contactsList"] as? [Any], var dataArray = JSONDeserializer<ContactModel>.deserializeModelArrayFrom(array: data) as? [ContactModel] {
                if let lastLoginUserName = UserDefaults.standard.value(forKey: RKLoginUDKeys.userNameKey) as? String {
                    dataArray.removeAll { model in
                        if model.username == lastLoginUserName {
                            ContactManager.shared.userInfo = model
                            return true
                        } else{
                            return false
                        }
                    }
                }
                kcontactList = dataArray
                ContactManager.shared.contactsListInfo = dataArray
                self.tableView.reloadData()
            }
        } onFailed: { error in
            
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
    
    ///20秒刷新一次
    var countdownTimer: Timer?
    private func setupTimer() {
        countdownTimer = Timer(timeInterval: 20, repeats: true) { [weak self] timer in
            if ((self?.hasShow) != nil) {
                self?.loadData()
            }
        }
        guard let countdownTimer = countdownTimer else { return }
        RunLoop.current.add(countdownTimer, forMode: RunLoopMode.defaultRunLoopMode)
        countdownTimer.fire()
    }
    
    deinit {
        countdownTimer?.invalidate()
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
        MeetingManager.shared.startMeeting(infos: choosedList, self)
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
            userIds.append(model.userId)
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
                return pModel.userId == model.userId
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
            return pModel.userId == model.userId
        }) {
            choosedList.removeAll { pModel in
                return pModel.userId == model.userId
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
//        let alertVC = RKAlertController.alertAlert(title: "收到\(fromUserId)邀请", message: channelId, okTitle: "加入", cancelTitle: "拒接") {
//            // 加入并接受
//            MeetingManager.shared.accept(meetingId: channelId, self)
//            // 超过60秒后 自动默认不能进入频道 超时移除
//            NSObject.cancelPreviousPerformRequests(withTarget: self)
//        } cancelComplete: {
//            // 拒接
//            RKCooperationCore.shared.getCallManager().reject(channelId: channelId, onSuccess: nil, onfailed: nil)
//            // 超过60秒后 自动默认不能进入频道 超时移除
//            NSObject.cancelPreviousPerformRequests(withTarget: self)
//        }
        let alertVC = RKAlertController.alertSheet(title: "收到\(fromUserId)邀请").add(title: "加入", style: .default) {
            // 加入并接受
            MeetingManager.shared.accept(meetingId: channelId, self)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }.add(title: "正忙", style: .destructive) {
            // 当前正在会议中，处理约等于拒接
            RKCooperationCore.shared.getCallManager().busy(channelId: channelId, onSuccess: nil, onfailed: nil)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }.add(title: "拒接", style: .destructive) {
            // 拒接
            RKCooperationCore.shared.getCallManager().reject(channelId: channelId, onSuccess: nil, onfailed: nil)
            // 超过60秒后 自动默认不能进入频道 超时移除
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }.add(title: "取消", style: .cancel, complete: nil).finish()
        
        self.present(alertVC, animated: true, completion: nil)
        self.perform(#selector(hidenJointAlert), with: alertVC, afterDelay: 60)
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
            MeetingManager.shared.joinMeeting(meetingId: channelId, self)
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
    
}

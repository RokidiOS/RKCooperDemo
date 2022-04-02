//
//  RKMeetingManager.swift
//  iOSRokid
//
//

import UIKit
import RKILogger
import RKCooperationCore
import QMUIKit

class MeetingManager: NSObject {
    
    static var shared: MeetingManager = MeetingManager()
    
    /// 上一次开启会议前的的控制器
    weak var lastBeforeMeetingVC: UIViewController?
    
    // 会议设置信息 不cache
    // 设置默认摄像头 默认使用后置
    var backCamera: Bool = true
    // 当前是否后置摄像头
    var currentBackCamera: Bool = false
    // 摄像头开关
    var cameraSwitch: Bool = true
    // 音频开关
    var audioSwitch: Bool = true
    // 扬声器开关
    var trumpetSwitch: Bool = true
  
    // 分辨率
    var maxResolution: RKResolution = .RESOLUTION_720
    // 会议名字
    var meetingName: String = ""

    // 会议频道
    //    private var _channel: RKChannel? = nil
    var channel: RKChannel?

    // 房间的所有成员id(包含未进入的)
    var roomMemberIds: NSMutableSet = []
     
    // MARK: - 清除会议缓存信息
    func clearMeeting() {
        channel = nil
        roomMemberIds.removeAllObjects()
        cameraSwitch = true
        audioSwitch = true
        trumpetSwitch = true
        maxResolution = .RESOLUTION_720

    }
    
    // MARK: - 单纯的创建个会议
    func createMeeting(meetingName: String,
                       password: String?,
                       userIds: [String]?,
                       maxResolution: RKResolution,
                       onSuccess: @escaping RKOnSuccess,
                       onFailed: @escaping RKOnFailed ) {
        
        RKCallManager.shared.createChannel(userIds: userIds, resolutionRatio: maxResolution, channelName: meetingName, password: password) { data in
            guard let dict = data as? [String: Any] else { return }
            if let channelId = dict["channelId"] as? String {
                // 拿到channel 赋值
                self.channel = RKChannelManager.shared.getChannel(channelId: channelId)
                self.channel?.channelName = meetingName
                onSuccess(nil)
            }
        } onFailed: { error in
            onFailed(error)
        }
        
    }
    

    
    private func joinMeeting(channelId: String) {
        // 创建并拿到 channel
        guard let channel = RKCooperationCore.shared.getChannelManager().create(channelId: channelId, channelTitle: nil, channelParam: nil) else {
            return
        }
        
        self.channel = channel
        
        RKCooperationCore.shared.getCallManager().accept(channelId: channelId)
        
    }
    
}

extension MeetingManager {
    
    // MARK: - 发起会议
    public func startMeeting(infos: [ContactModel], _ vc: UIViewController) {
        lastBeforeMeetingVC = vc
        let callSettingVC = CallPreVC()
        var userIds: [String] = []
        infos.forEach { contact in
            userIds.append(contact.userId)
        }
        callSettingVC.userIds = userIds
        callSettingVC.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(callSettingVC, animated: true)
    }

    public func inviteMeeting(_ infos: [ContactModel]) {
        guard let channel = channel else { return }
        var userIds: [String] = []
        infos.forEach { contact in
            userIds.append(contact.userId)
        }
        RKCooperationCore.shared.getCallManager().invite(channelId: channel.channelId, userIdList: userIds)
    }
    
    public func joinMeeting(meetingId: String, _ vc: UIViewController) {
        joinMeeting(channelId: meetingId)
        let meetVC = MideaRoomVC()
        lastBeforeMeetingVC = vc
        vc.navigationController?.pushViewController(meetVC, animated: true)
    }
    
    // MARK: - 结束会议
    public func leaveMeeting() {
        
        channel?.leave()
        clearMeeting()
        RKShareDoodleManager.shared.clear()
        guard let lastBeforeMeetingVC = lastBeforeMeetingVC else { return }
        
        ///退回到发起视频之前的会议
        lastBeforeMeetingVC.navigationController?.popToViewController(lastBeforeMeetingVC, animated: true)

    }
    
    
}

// MARK: - 呼叫相关
extension MeetingManager: RKIncomingCallListener {
    
    // MARK: - 添加来电监听
    func addIncomingCallListener() {
        
        RKCooperationCore.shared.getCallManager().addIncomingCall(listener: self)
        
    }
    
    func onReceiveCall(channelId: String, fromUserId: String, createTime: Int64, channelTitle: String?) {
        
        guard Int64(Date().timeIntervalSince1970 * 1000) - createTime < 60 * 1000 else {
            RKLog("收到\(fromUserId)的来电，已超时...")
            return
        }
        

    }
    
    func onCallCanceled(channelId: String, fromUserId: String, createTime: Int64) {
        
        MeetingManager.shared.clearMeeting()
        
    }
    /// 当前是否允许进行下一步操作 ** 主动调用当前如果是close会清空shareinfo
    func isAllowNextShareAction() -> Bool {
        if let shareInfo = channel?.shareInfo {
            if shareInfo.shareType == .close {
                channel?.shareInfo = nil
                return true
            }
            if shareInfo.shareType == .videoControl {
                return true
            }
            return false
        }
        
        return true
    }
}

extension MeetingManager {
    
    func showError() {
        guard let shareInfo = channel?.shareInfo,
              let contactInfo = ContactManager.shared.contactFrom(userId: shareInfo.executorUserId) else {
                  return
              }
        
        var errString = ""
        if shareInfo.shareType == .screen {
            errString = "\(contactInfo.realName)正在分享屏幕"
        } else if shareInfo.shareType == .doodle {
            errString = "\(contactInfo.realName)正在电子白板"
        } else if shareInfo.shareType == .imageDoodle {
            errString = "\(contactInfo.realName)正在冻屏标注"
        } else if shareInfo.shareType == .slam {
            errString = "\(contactInfo.realName)正在AR标注"
        } else if shareInfo.shareType == .pointVideo {
            errString = "正在视频点选"
        } else if shareInfo.shareType == .videoControl {
            errString = "\(contactInfo.realName)正在视频控制"
        }
        
        if errString.isEmpty == false {
            QMUITips.showError(errString)
        }
    }
    
}

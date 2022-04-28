//
//  RKMeetingManager.swift
//  iOSRokid
//  会议管理Manager
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
        // 根据业务是否需要重置之前的麦克风权限
        //        MeetingManager.shared.channel?.enableUploadLocalVideoStream(enable: false)
        MeetingManager.shared.audioSwitch = true
        MeetingManager.shared.channel?.shareInfo = nil
        channel = nil
        roomMemberIds.removeAllObjects()
        cameraSwitch = true
        audioSwitch = true
        trumpetSwitch = true
        
        maxResolution = .RESOLUTION_720
        
    }
    
    // MARK: - 单纯的创建个会议
    func createMeeting(meetingName: String,
                       userIdLiset: [String],
                       channelParam: RKChannelParam,
                       onSuccess: @escaping RKOnSuccess,
                       onFailed: @escaping RKOnFailed) {
        
        RKChannelManager.shared.create(channelId: nil, channelTitle: meetingName, channelParam: channelParam, userIdList: userIdLiset,onSuccess: { data in
            if let channel = data as? RKChannel {
                self.channel = channel
                onSuccess (channel)
            } else {
                onFailed(nil)
            }
        }, onfailed: onFailed)
    }
    
    private func joinMeeting(channelId: String, onSuccess: RKOnSuccess?, onfailed: RKOnFailed?) {
        // 创建并拿到 channel
        RKChannelManager.shared.join(channelId: channelId, channelPassword: nil,onSuccess: { data in
            guard let channel = RKCooperationCore.shared.getChannelManager().getChannel(channelId: channelId ) else {
                onfailed? (nil)
                return
            }
            self.channel = channel
            // 接受邀请
            RKCooperationCore.shared.getCallManager().accept(channelId: channelId, onSuccess: onSuccess, onfailed: onfailed)
        }, onFailed: onfailed)
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
    
    public func inviteMeeting(_ userIdList: [String]) {
        guard let channel = channel else { return }
        RKCooperationCore.shared.getCallManager().invite(channelId: channel.channelId, userIdList: userIdList) { data in
            guard let data = data as? [String], data.isEmpty == false else {
                // 全部邀请成功
                return
            }
            // 重复邀请的用户
            
            var userNameList: [String] = []
            data.forEach { userId in
                if let contact = ContactManager.shared.contactFromUserId[userId] {
                    userNameList.append(contact.realName)
                }
            }
            
            QMUITips.showError("\(userNameList) 已经在会议中!")
        } onfailed: { error in
            QMUITips.showError("邀请失败\(String(describing: error))")
        }
    }
    
    public func joinMeeting(meetingId: String, _ vc: UIViewController) {
        joinMeeting(channelId: meetingId) { _ in
            let meetVC = MideaRoomVC()
            self.lastBeforeMeetingVC = vc
            vc.navigationController?.pushViewController(meetVC, animated: true)
        } onfailed: { error in
            QMUITips.showError("进入房间失败 \(String(describing: error))")
        }
        
        
    }
    
    public func accept(meetingId: String, _ vc: UIViewController) {
        guard let channel = RKCooperationCore.shared.getChannelManager().getChannel(channelId: meetingId ) else {
            return
        }
        self.channel = channel
        // 接受邀请
        RKCooperationCore.shared.getCallManager().accept(channelId: meetingId, onSuccess: { data in
            let meetVC = MideaRoomVC()
            self.lastBeforeMeetingVC = vc
            vc.navigationController?.pushViewController(meetVC, animated: true)

        }, onfailed: { error in
            QMUITips.showError("进入房间失败 \(String(describing: error))")
        })
    }

    
    // MARK: - 结束会议
    public func leaveMeeting() {
        // 离开会议
        channel?.leave()
        // 重置会议缓存信息
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

}


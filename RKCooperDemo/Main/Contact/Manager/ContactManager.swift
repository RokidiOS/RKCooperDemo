//
//  RKContactManager.swift
//  联系人管理manager

import UIKit
import RKILogger
import RKCooperationCore

let kNotiContactMgrDidRefresh: String = "kNotiContactMgrDidRefresh"

@objcMembers
class ContactManager: NSObject {
    
    static var shared = ContactManager()
    
    var refreshToken: String?
    
    var selfUserId: String = ""
    
    var timer: DispatchSourceTimer? = nil
    
    var contactFromUserId: String  = ""
    
    
    
    var contactsListInfo = [String]()
//    {
//        didSet {
//            for (_, item) in contactsListInfo.enumerated() {
//                contactFromUserId[item.userId] = item
//                contactfromUserName[item.username] = item
//            }
//        }
//    }
    
   

}

extension ContactManager {
    
    // MARK: - 登出
    func logOut() {
        gotoLoginVC()
    }
    
    // MARK: - 执行登出操作
    func gotoLoginVC() {
        // 移除SDK window
        MeetingManager.shared.leaveMeeting()
    }
    
}

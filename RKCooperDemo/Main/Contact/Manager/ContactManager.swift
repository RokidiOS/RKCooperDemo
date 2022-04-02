//
//  RKContactManager.swift

import UIKit
import RKILogger
import RKCooperationCore

let kNotiContactMgrDidRefresh: String = "kNotiContactMgrDidRefresh"

@objcMembers
class ContactManager: NSObject {
    
    static var shared = ContactManager()
    
    var userInfo = ContactModel()
    
    var timer: DispatchSourceTimer? = nil
    
    var contactFromUserId: [String: ContactModel] = [:]
    
    var contactfromUserName: [String: ContactModel] = [:]
    
    var contactsListInfo = [ContactModel]() {
        didSet {
            for (_, item) in contactsListInfo.enumerated() {
                contactFromUserId[item.userId] = item
                contactfromUserName[item.username] = item
            }
        }
    }
    
    func contactFrom(userId: String) -> ContactModel? {
        return self.contactFromUserId[userId]
    }
    
    
    func startLoop() {
        if self.timer != nil {
            self.timer!.cancel()
        }
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer.schedule(deadline: .now() + 5.0, repeating: .seconds(5), leeway: .milliseconds(10))
        timer.setEventHandler(handler: {
            self.setupcontactsListInfoData()
        })
        
        self.timer = timer
        self.timer?.resume()
    }
    
    func setupcontactsListInfoData() {
//        RKAPIManager.shared.contactsList(keyword: nil) { data in
//            if let data = data as? NSDictionary,
//               let obj = RKContactListModel.deserialize(from: data){
//                self.contactsListInfo = obj
//                NotificationCenter.default.post(name: NSNotification.Name(kNotiContactMgrDidRefresh), object: nil)
//            }
//        } onFailed: { error in
//            if RKAuthInfo.authorization == "" {
//                self.cancel()
//            }
//        }
    }
    
    func cancel() {
        self.timer?.cancel()
    }
    
}

extension ContactManager {
    
    // MARK: - 登出
    func logOut() {
        
//        guard RKAuthInfo.isLogin() else {
//            return
//        }
//
//        RKAuthInfo.authorization = ""
//
//        RKCooperationCore.shared.logout()
//
//        RKHeartBeatManager.shared.stop()
//
//        RKLog(String(describing: self))
        
        gotoLoginVC()
    }
    
    // MARK: - 执行登出操作
    func gotoLoginVC() {
        // 移除SDK window
        MeetingManager.shared.leaveMeeting()
        // 返回登录页面
//        if let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
//            for viewController in rootNav.viewControllers {
//                if viewController is RKLoginViewController {
//                    rootNav.popToViewController(viewController, animated: true)
//                    break
//                }
//            }
//        }
    }
    
}

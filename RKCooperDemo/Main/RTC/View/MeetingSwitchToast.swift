//
//  CallSwitchToast.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/28.
//

import UIKit
import RKIUtils
import QMUIKit

public enum SwitchType: String {
    case audioOn = "已开启麦克风"
    case audioOff = "已关闭麦克风"
    case trumpetOn = "已开启扬声器模式"
    case trumpetOff = "已开启听筒模式"
    case cameraOn = "已开启摄像头"
    case cameraOff = "已关闭摄像头"
    case cameraSwitch = "已切换摄像头"
    case muteOn = "已发起全员静音"
    case muteOff = "已解除全员静音"
    
    case imageSaved = "图片已保存到本地"
    case markClear = "已清空标注内容"
    case markClearClearByOther = "清空了标注内容"

    case doodleStart = "已发起电子白板"
    case doodleStartByOther = "发起了电子白板"
    case doodleClear = "已清空白板内容"

    case doodleImageStart = "已发起冻屏标注"
    case doodleImageStartByOther = "发起了冻屏标注"

    case screenStart = "已发起屏幕共享"
    case screenStartByOther = "发起了屏幕共享"
    case screenUnSupport = "当前设备不支持 屏幕共享"

    case slamStart = "已发起AR标注"
    case slamStartByOther = "发起了AR标注"
    case slamUnSupport = "当前设备不支持 AR标注"
    
    case pointStart = "已发起视频点选"
    case pointStartByOther = "发起了视频点选"

    case videoCtrlStart = "已发起视频控制"
    case videoCtrl = "发起了视频控制"
}

public struct MeetingSwitchToast {
    
    static func show(_ switchType: SwitchType, inView: UIView?) {
        if let view = inView {
            
            QMUITips.showInfo(switchType.rawValue, in: view)
        } else if let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            QMUITips.showInfo(switchType.rawValue, in: rootNav.view)
        }
    }
    
    static func show(_ title: String,  _ switchType: SwitchType, inView: UIView?) {
        if let view = inView {
            QMUITips.showInfo(title + switchType.rawValue, in: view)
        } else if let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            QMUITips.showInfo(title + switchType.rawValue, in: rootNav.view)
        }
    }
}

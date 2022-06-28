//
//  ContactModel.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RKIHandyJSON

class ContactModel: NSObject, HandyJSON {
    // 手机号
    var phoneNum: String = ""
    // 部门名称
    var postName: String = ""
    // 真实姓名
    var realName: String = ""
    // 单位名称
    var unitName: String = ""
    // 用户id
    var userId: String = ""
    // 用户名
    var username: String = ""
    // 头像url
    var headUrl: String = ""
    
    required override init() {}
}

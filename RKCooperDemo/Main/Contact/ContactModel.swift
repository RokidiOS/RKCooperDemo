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

    var phoneNum: String = ""
    
    var postName: String = ""
    
    var realName: String = ""
    
    var unitName: String = ""
    
    var userId: String = ""
    
    var username: String = ""
    
    var headUrl: String = ""
    
    var status: Bool = false
    required override init() {}
}

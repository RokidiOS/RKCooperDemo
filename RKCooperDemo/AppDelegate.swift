//
//  AppDelegate.swift
//  RKCooperDemo
//
//  Created by chzy on 03/11/2022.
//  Copyright (c) 2022 chzy. All rights reserved.
//

import UIKit
import QMUIKit
import DoraemonKit
import Bugly

enum deviceOrient {
    case all
    case landscape
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var rotation: deviceOrient = .all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        TestHelper.enableTestSetting()
        
        Bugly.start(withAppId: "75190bc727")
        
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch rotation {
        case .all:
            return .all
        case .landscape:
            return .landscape
        }
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
    }
    
}


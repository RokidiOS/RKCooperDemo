//
//  ThemeDefine.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

public class RKColor: NSObject {
    public static let BgColor = { return UIColor.init(hex: 0x2A2C30) }()
    
    public static let offlineClr = { return UIColor(hex: 0x606060) }()
    public static let onlineClr = { return UIColor(hex: 0x39FF7F) }()
    public static let cooperateClr = { return UIColor(hex: 0xF86847) }()
    
    public static let lineClr = { return UIColor(hex: 0x979797) }()
    
    public static let roomCellBgClr = { return UIColor(hex: 0x252531) }()
    public static let roomBarSettingClr = { return UIColor(hex: 0x101018) }()
    public static let roomBarNavBgClr = { return UIColor(hex: 0x2A2C30) }()
    // 按钮蓝色
    public static let alertButtonClr = { return UIColor(hex: 0x408CFF) }()
    
    
    // 背景颜色
    public static let color_bg_nomal   = { return UIColor(hex: 0xF8F9FB) }()
    
    // 文字颜色
    public static let color_text_title = { return UIColor(hex: 0x616978) }()
    
}

public class RKFont: NSObject {
    // 提示文本
    public static let font_tipText          = { return UIFont.systemFont(ofSize: 12) }()
    // 一般文本
    public static let font_nomalText        = { return UIFont.systemFont(ofSize: 14) }()
    // 主要文本
    public static let font_mainText         = { return UIFont.systemFont(ofSize: 16) }()
    public static let font_mainText_bold    = { return UIFont.boldSystemFont(ofSize: 16) }()

    // 次要文本
    public static let font_contentText      = { return UIFont.systemFont(ofSize: 18) }()
    public static let font_contentText_bold = { return UIFont.boldSystemFont(ofSize: 18) }()

    // 三级标题
    public static let font_thirdTitle       = { return UIFont.systemFont(ofSize: 20) }()
    public static let font_thirdTitle_bold  = { return UIFont.boldSystemFont(ofSize: 20) }()
    
    // 二级标题
    public static let font_secondTitle      = { return UIFont.systemFont(ofSize: 24) }()
    // 二级标题
    public static let font_secondTitle_bold = { return UIFont.boldSystemFont(ofSize: 24) }()
    // 一级标题
    public static let font_title            = { return UIFont.systemFont(ofSize: 30) }()
    
}

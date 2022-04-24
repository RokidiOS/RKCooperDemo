//
//  ChannelConfigVC.swift
//  RKCooperDemo
//
//  Created by chzy on 2022/4/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//  参数配置页面

import UIKit
import RKCooperationCore
import QMUIKit
import RKIUtils

class ChannelConfigVC: UIViewController {
    
    var okClick: ((RKChannelParam) ->Void)?
    var param = RKChannelParam()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "配置频道参数"
        view.backgroundColor = .white
        
        add("请输入房间密码") { [weak self] tf in
            if let pwd = tf.text {
                self?.param.password = pwd
            }
        }.add("请输入码率") { [weak self] tf in
            if let codeRate = tf.text,
               let codeRateInt = Int32(codeRate) {
                self?.param.bitrate = codeRateInt
            }
        }.add("请输入最大延迟") {[weak self] tf in
            if let maxDelay = tf.text,
               let maxDelayInt = Int32(maxDelay) {
                self?.param.maxDelay = maxDelayInt
            }
        }
    
        let okItem = UIBarButtonItem(title: "配置", style: .done, target: self, action: #selector(configAction))
        navigationItem.rightBarButtonItem = okItem
        
        var lastView: UIView?
        for (tf, _) in tuples {
            view.addSubview(tf)
            tf.snp.makeConstraints { make in
                make.centerX.equalTo(view)
                make.height.equalTo(40)
                if let lastView = lastView {
                    make.top.equalTo(lastView.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(UI.SafeTopHeight + 20 + 64)
                }
                make.width.equalToSuperview().offset(-30)
            }
            lastView = tf
        }
    }
    
    @objc private func configAction() {
        for (tf, block) in tuples {
            block(tf)
        }
        okClick?(param)
        QMUITips.showSucceed("设置成功")
        navigationController?.popViewController(animated: true)
    }
    
    private var tuples = [(QMUITextField, (QMUITextField) ->Void)]()
    
    @discardableResult
    func add(_ title: String, clickBlock:@escaping (QMUITextField) ->Void) -> ChannelConfigVC {
        let tf = QMUITextField()
        tf.maximumTextLength = 20
        tf.keyboardType = .numberPad
        tf.placeholder = title
       
        tuples.append((tf, clickBlock))
        return self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TempTool.forceOrientationPortrait()
    }
}

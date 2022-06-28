//
//  TestHelper.swift
//  RKCooperDemo
//
//  Created by chzy on 2022/6/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import DoraemonKit
import RKCooperationCore
import UIKit
import QMUIKit
import RKIUtils

class TestHelper {
    static func enableTestSetting() {
        DoraemonManager.shareInstance().install()
        let dManager = DoraemonCacheManager.sharedInstance()
        DoraemonManager.shareInstance().pId = "095aa8f3a6d3fba7ca573552dfb93bd6"
        ///默认打开crash
        dManager?.saveCrashSwitch(true)
        
        //默认打开leak
        dManager?.saveMemoryLeak(true)
        
        dManager?.saveANRTrackSwitch(true)
        
        DoraemonManager.shareInstance().addPlugin(withTitle: "默认参数设置", image: UIImage(named: "ic_call_room_member_detail_all_sound_off")!, desc: "设置默认大小流以及音视频订阅", pluginName: "Demo设置", atModule: "Demo设置", handle: { _ in
            let setVC = DefaultSetVC()
            DoraemonHomeWindow .openPlugin(setVC)
        })
         
    }
     
    
}


class DefaultSetVC: UIViewController {
        
    override func viewDidLoad() {
        self.title = "设置默认参数"
        view.backgroundColor = .white
        
        view.addSubViews([streamSegmentedControl, mediaSegmentedControl])
        streamSegmentedControl.backgroundColor = .blue.withAlphaComponent(0.6)
        mediaSegmentedControl.backgroundColor = .blue.withAlphaComponent(0.6)
         
        let gap: CGFloat = 15 + 20
        let naviHeight: CGFloat = navigationController?.navigationBar.qmui_height ?? 64
        streamSegmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(UI.SafeTopHeight + naviHeight + gap)
            make.width.equalToSuperview().offset(-60)
        }
        
        mediaSegmentedControl.snp.makeConstraints { make in
            make.height.width.centerX.equalTo(streamSegmentedControl)
            make.top.equalTo(streamSegmentedControl.snp.bottom).offset(gap)
        }
        
        mediaSegmentedControl.selectedSegmentIndex =  MeetingManager.shared.defaultSubscribeMediaType.rawValue
        
        streamSegmentedControl.selectedSegmentIndex = MeetingManager.shared.defaultStreamType ? 1 : 0
        
        mediaSegmentedControl.addTarget(self, action: #selector(saveAction(_:)), for: .valueChanged)
      
        streamSegmentedControl.addTarget(self, action: #selector(saveAction(_:)), for: .valueChanged)
        
    }
    
    private let streamSegmentedControl = QMUISegmentedControl(items: ["小流", "大流"])
    
    private let mediaSegmentedControl = QMUISegmentedControl(items: ["全部订阅", "仅音频", "仅视频", "都不订阅"])
    
    @objc func saveAction(_ control: QMUISegmentedControl) {
        if control == streamSegmentedControl {
            MeetingManager.shared.defaultStreamType = control.selectedSegmentIndex == 1
        } else if control == mediaSegmentedControl {
            MeetingManager.shared.defaultSubscribeMediaType = SubscribeMediaType(rawValue: control.selectedSegmentIndex) ?? .both
        }
    }
    
}



class PerUserSetVC: UIViewController {
    var user: RKChannelParticipant?
    
    override func viewDidLoad() {
        if let  user = user {
            self.title = "设置 \(user.userId) 订阅参数"
        }

        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.topMargin.equalTo(50)
            make.left.equalTo(UI.SafeTopHeight + 50)
            make.width.height.equalTo(50)
        }
        
        
        view.backgroundColor = .white
        
        view.addSubViews([streamSegmentedControl, mediaSegmentedControl])
        streamSegmentedControl.backgroundColor = .blue.withAlphaComponent(0.6)
        mediaSegmentedControl.backgroundColor = .blue.withAlphaComponent(0.6)
        
        let gap: CGFloat = 15 + 20
        streamSegmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(backBtn.snp.bottom).offset(gap)
            make.width.equalToSuperview().offset(-60)
        }
        
        mediaSegmentedControl.snp.makeConstraints { make in
            make.height.width.centerX.equalTo(streamSegmentedControl)
            make.top.equalTo(streamSegmentedControl.snp.bottom).offset(gap)
        }
                
        guard let user = user else { return }

        mediaSegmentedControl.selectedSegmentIndex =  user.mediaSubscribeState.rawValue
        
        streamSegmentedControl.selectedSegmentIndex = user.isHighStream ? 1 : 0
        
        mediaSegmentedControl.addTarget(self, action: #selector(saveAction(_:)), for: .valueChanged)
      
        streamSegmentedControl.addTarget(self, action: #selector(saveAction(_:)), for: .valueChanged)
    }
    
    private let streamSegmentedControl = QMUISegmentedControl(items: ["小流", "大流"])
    
    private let mediaSegmentedControl = QMUISegmentedControl(items: ["全部订阅", "仅音频", "仅视频", "都不订阅"])
        
    @objc func saveAction(_ control: QMUISegmentedControl) {
        guard let user = user else { return }
        if control == streamSegmentedControl {
            user.switchStream(isHighStream: control.selectedSegmentIndex == 1, onSuccess: { _ in
                
            }, onFailed: {_ in
                
            })
        } else if control == mediaSegmentedControl {
            let state = SubscribeMediaType(rawValue: control.selectedSegmentIndex) ?? .both
            user.subscribeStateChange(state) { data in
                
            } onFailed: { error in
                
            }

        }
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var backBtn: UIButton = {
        return createBtn("rk_alert_close", #selector(backAction))
    }()
    
    private func createBtn(_ name: String, _ selectror: Selector) -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: name), for: .normal)
        btn.addTarget(self, action: selectror, for: .touchUpInside)
        return btn
    }
    
}

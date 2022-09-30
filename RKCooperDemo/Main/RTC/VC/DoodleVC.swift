//
//  DoodleVC.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/21.
//  Copyright © 2022 CocoaPods. All rights reserved.
//  电子白板

import UIKit
import RKCooperationCore
import SnapKit
import QMUIKit
import RKIUtils

class DoodleVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(drawView)
        view.backgroundColor = .white
        drawView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubViews([backBtn, revokebtn, clearbtn, snapshotBtn, reduceBtn])
        
        backBtn.snp.makeConstraints { make in
            make.topMargin.equalTo(50)
            make.left.equalTo(UI.SafeTopHeight + 50)
            make.width.height.equalTo(50)
        }
        
        revokebtn.snp.makeConstraints { make in
            make.top.equalTo(backBtn.snp.bottom).offset(30)
            make.topMargin.equalTo(30)
            make.left.width.height.equalTo(backBtn)
        }
        
        clearbtn.snp.makeConstraints { make in
            make.top.equalTo(revokebtn.snp.bottom).offset(30)
            make.left.width.height.equalTo(backBtn)
        }
        
        snapshotBtn.snp.makeConstraints { make in
            make.top.equalTo(clearbtn.snp.bottom).offset(30)
            make.left.width.height.equalTo(backBtn)
        }
        
        reduceBtn.snp.makeConstraints { make in
            make.topMargin.equalTo(50)
            make.right.equalTo(-50)
            make.width.height.equalTo(50)
        }
    }
    
    @objc private func reduceAction() {
        guard let vcs = self.navigationController?.viewControllers else { return }
        for vc in vcs.reversed() {
            if !vc.isKind(of: DoodleVC.self) {
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
       
    }
    
    @objc private func backAction() {
        if let channel = MeetingManager.shared.channel,
           let shareInfo = channel.shareInfo,
           shareInfo.shareType == .doodle || shareInfo.shareType == .imageDoodle {
            if shareInfo.promoterUserId != RKUserManager.shared.userId {
                QMUITips.showError("非发起者不能终止")
                return
            }
        }
      
        
        let alertController = QMUIAlertController(title: "确定要退出绘制模式", message: nil, preferredStyle: .alert)
      
        let doneAction = QMUIAlertAction(title: "确定", style: .default) { _, _ in
            guard let channel = MeetingManager.shared.channel else { return }
            self.doodelManager.stopShareDoodle(timeoutSec:0, channelId: channel.channelId) { data in
                self.navigationController?.popViewController(animated: true)
            } onFailed: { error in
                
            }

           
        }
        
        let cancelAction = QMUIAlertAction(title: "取消", style: .cancel) { _, _ in
            
        }
        alertController.addAction(doneAction)
        alertController.addAction(cancelAction)
        alertController.showWith(animated: true)
    }
    
    @objc private func revokeAction() {
        guard let channel = MeetingManager.shared.channel else { return }
        doodelManager.revoke(channelId: channel.channelId, doodle: nil)
    }
    
    @objc private func cleanAction() {
        guard let channel = MeetingManager.shared.channel else { return }
        doodelManager.clear(channelId: channel.channelId)
    }
    
    @objc fileprivate func snapshotAction() {
        let drawImage = drawView.qmui_snapshotLayerImage()
        UIImageWriteToSavedPhotosAlbum(drawImage, self, #selector(self.savedPhotosAlbum(image:didFinishSavingWithError:contextInfo:)), nil);
    }
    
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if let error = error {
            QMUITips.showError("截图保存失败, \(error.localizedDescription)")
        } else {
            QMUITips.showError("截图已保存到相册.")
        }
    }
    
    lazy var drawView: RKDrawView = {
        let drawView = doodelManager.drawView
        drawView.lineColor = .red
        drawView.lineWidth = 2.0
        return drawView
    }()
    
    lazy var backBtn: UIButton = {
        return createBtn("rk_alert_close", #selector(backAction))
    }()
  
    lazy var reduceBtn: UIButton = {
        return createBtn("ic_call_room_member_detail_back", #selector(reduceAction))
    }()
    
    lazy var revokebtn: UIButton = {
        return createBtn("media_function_revoke_n", #selector(revokeAction))
    }()
    
    lazy var snapshotBtn: UIButton = {
        return createBtn("media_function_file_n", #selector(snapshotAction))
    }()
    
    lazy var clearbtn: UIButton = {
        return createBtn("media_function_delete_n", #selector(cleanAction))
    }()
    
    private func createBtn(_ name: String, _ selectror: Selector) -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: name), for: .normal)
        btn.addTarget(self, action: selectror, for: .touchUpInside)
        return btn
    }
    
    lazy var doodelManager: RKShareDoodleManager = {
        return RKCooperationCore.shared.getShareDoodleManager()
    }()
}

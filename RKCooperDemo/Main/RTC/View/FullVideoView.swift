//
//  FullVideoView.swift
//  RKCooperDemo_Example
//
//  Created by chzy on 2022/3/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//  全屏视频流 view

import UIKit
import SnapKit

protocol FullVideoViewDelegate: NSObjectProtocol {
    // 全屏视图关闭回调
    func fullVideoViewDidHidden(_ userId: String)
    // 截图
    func screenSnapshot(_ userId: String)
}

class FullVideoView: UIView {
    var lastVideoSuperView: UIView?
    var lastVieoView: UIView?
    var userId: String = ""

    weak var delegate: FullVideoViewDelegate?
    
    init() {
        super.init(frame: .zero)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hidenAction))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
        
        addSubview(snapBtn)
        snapBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.right.equalTo(-30)
            make.centerY.equalToSuperview()
        }
        
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
            make.bottom.equalToSuperview().offset(-40)
        }
        
    }
    
    public func showInfo(_ string: String) {
        infoLabel.text = string
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        bringSubview(toFront: infoLabel)
        bringSubview(toFront: snapBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private lazy var snapBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_call_room_member_take_photo"), for: .normal)
        btn.addTarget(self, action: #selector(snapAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var infoLabel: UILabel = {
        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.numberOfLines = 0
        infoLabel.setContentHuggingPriority(.required
                                            , for: .vertical)
        infoLabel.textColor = .white
        return infoLabel
    }()
    
    // 缩小 隐藏操作
    @objc private func hidenAction() {
        guard let lastVideoSuperView = lastVideoSuperView else { return }
        guard let lastVieoView = lastVieoView else { return }
        self.snp.remakeConstraints { make in
            make.edges.equalTo(lastVideoSuperView)
        }
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            lastVideoSuperView.addSubview(lastVieoView)
            lastVideoSuperView.sendSubview(toBack: lastVieoView)
            lastVieoView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }

            self.isHidden = true
            self.delegate?.fullVideoViewDidHidden(self.userId)
        }

    }
    
    // 截屏操作
    @objc private func snapAction() {
        self.delegate?.screenSnapshot(self.userId)
    }
}

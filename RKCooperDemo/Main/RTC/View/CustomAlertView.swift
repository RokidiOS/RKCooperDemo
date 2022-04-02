//
//  CustomAlertView.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/21.
//

import UIKit
import RKIUtils

typealias AlertHandler = () -> Void

class CustomAlertView: RKMaskView {
    
    var contentView: UIView!
    var titleLabel: UILabel!
    var contentLabel: UILabel!
    var cancelButton: UIButton!
    var confirmButton: UIButton!
    var alertCancelHandler: AlertHandler?
    var alertConfirmHandler: AlertHandler?
    var lineH: UIView!
    var lineV: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func setupView()  {
        
        super.setupView()
        
        contentView = UIView()
        contentView.backgroundColor = RKColor.BgColor
        contentView.layer.cornerRadius = 12
        self.addSubview(contentView)
        
        titleLabel = UILabel()
        titleLabel.font = RKFont.font_nomalText
        titleLabel.textAlignment = .center
        titleLabel.textColor = .init(hex: 0xFFFFFF)
        contentView.addSubview(titleLabel)
        
        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.font = RKFont.font_tipText
        contentLabel.textAlignment = .center
        contentLabel.textColor = .init(hex: 0xFFFFFF, alpha:0.5)
        contentView.addSubview(contentLabel)
        
        cancelButton = UIButton(type:.custom)
        cancelButton.titleLabel!.font = RKFont.font_nomalText
        cancelButton.setTitleColor(.init(hex: 0xFFFFFF, alpha: 0.5), for: .normal)
        cancelButton.addTarget(self, action: #selector(customActionBtnClicked(_:)), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        
        confirmButton = UIButton(type:.custom)
        confirmButton.titleLabel!.font = RKFont.font_nomalText
        confirmButton.setTitleColor(RKColor.alertButtonClr, for: .normal)
        confirmButton.addTarget(self, action: #selector(customActionBtnClicked(_:)), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        
        lineH = UIView()
        lineH.backgroundColor = RKColor.lineClr
        contentView.addSubview(lineH)
        lineH.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-38)
            make.height.equalTo(0.5)
        }
        
        lineV = UIView()
        lineV.backgroundColor = RKColor.lineClr
        contentView.addSubview(lineV)
        lineV.snp.makeConstraints { (make) in
            make.height.equalTo(38)
            make.width.equalTo(0.5)
            make.bottom.centerX.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(266)
            make.height.equalTo(146)
            make.centerX.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerY.equalTo(35)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(70)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(38)
            make.right.equalTo(contentView.snp.centerX)
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.width.height.equalTo(cancelButton)
            make.left.equalTo(contentView.snp.centerX)
        }
    }
    
    func showAlertView(_ view: UIView?,
                       _ title: String,
                       _ content: String,
                       _ cancelTitle: String?,
                       _ confirmTitle: String?,
                       _ cancelAction: @escaping AlertHandler,
                       _ confirmAction:@escaping AlertHandler) {
        if let view = view {
            view.addSubview(self)
        } else {
            if let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                rootNav.view.addSubview(self)
            }
        }
        
        self.alertCancelHandler = cancelAction
        self.alertConfirmHandler = confirmAction
        
        self.snp.makeConstraints { (make) in
            make.top.left.width.height.equalToSuperview()
        }
        
        titleLabel.text = title
        
        contentLabel.text = content
        
        // 没有content
        if content.isEmpty == true {
            contentLabel.isHidden = true
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.centerY.equalTo(60)
            }
        }
        
        // 没有title
        if title.isEmpty == true {
            titleLabel.isHidden = true
            contentLabel.snp.remakeConstraints { make in
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.centerY.equalTo(60)
            }
        }
        
        if cancelTitle != nil {
            cancelButton.setTitle(cancelTitle, for: .normal)
        }
        
        if confirmTitle != nil {
            confirmButton.setTitle(confirmTitle, for: .normal)
        }
        
        if cancelTitle == nil {
            lineV.isHidden = true
            confirmButton.snp.makeConstraints { (make) in
                make.left.width.equalToSuperview()
            }
        }
        
        if confirmTitle == nil {
            lineV.isHidden = true
            cancelButton.snp.makeConstraints { (make) in
                make.left.width.equalToSuperview()
            }
        }
    }
    
    @objc func customActionBtnClicked(_ sender: UIButton) {
        self.alpha = 0
        self.removeFromSuperview()
        switch sender {
        case cancelButton:
            alertCancelHandler?()
        case confirmButton:
            alertConfirmHandler?()
        default: break
        }
    }
}

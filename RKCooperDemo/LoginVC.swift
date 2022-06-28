//
//  ViewController.swift
//  RKCooperDemo
//
//  Created by chzy on 03/11/2022.
//  Copyright (c) 2022 chzy. All rights reserved.
//

import UIKit
import RKCooperationCore
import QMUIKit
import SnapKit
import RKSassLog
import RKILogger

struct RKLoginUDKeys {
    static let companyIdKey = "LastLoginCompanyIdKey"
    static let userNameKey = "LastLoginUserNameKey"
    static let passwordKey = "LastLoginUserPasswordKey"
}

class LoginVC: UIViewController {
    
    var appId: String = "135D8B743401461C95905C3B2822B81C"
    
    var apiServer: String = ""
    
    // 登录完成后 查询回调
    var loginQueryBlock:(() ->Void)?
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubViews([companyTextFiled,
                          userTextFiled,
                          passwordTextFiled,
                          loginButton,
                          configButton])
        layoutViews()
        if let lastLoginCompanyId = UserDefaults.standard.value(forKey: RKLoginUDKeys.companyIdKey) as? String,
           let lastLoginUserName = UserDefaults.standard.value(forKey: RKLoginUDKeys.userNameKey) as? String,
           let lastpassword = UserDefaults.standard.value(forKey: RKLoginUDKeys.passwordKey) as? String{
            self.companyTextFiled.text = lastLoginCompanyId
            self.userTextFiled.text = lastLoginUserName
            self.passwordTextFiled.text = lastpassword
            loginAction()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TempTool.forceOrientationPortrait()
    }
    
    private func layoutViews() {
        let titleLable = UILabel()
        titleLable.textAlignment = .center
        titleLable.font = UIFont.boldSystemFont(ofSize: 20)
        titleLable.textColor = UIColor(hex: 0x2D2D2D)
        titleLable.text = "RKCoreExample"
        self.view.addSubview(titleLable)
        
        
        titleLable.snp.makeConstraints { (make) in
            make.topMargin.equalTo(80)
            make.left.right.equalToSuperview()
        }
        
        companyTextFiled.snp.makeConstraints { make in
            make.top.equalTo(titleLable.snp.bottom).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
        }
        
        userTextFiled.snp.makeConstraints { (make) in
            make.top.equalTo(companyTextFiled.snp.bottom).offset(18)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
        }
        
        passwordTextFiled.snp.makeConstraints { (make) in
            make.top.equalTo(userTextFiled.snp.bottom).offset(18)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextFiled.snp.bottom).offset(28)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(42)
        }
        
        configButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(42)
        }
    }
    
    lazy var companyTextFiled: QMUITextField = {
        let tf = createTf("请输入公司名")
        tf.keyboardType = .asciiCapable
        return tf
    }()
    
    lazy var userTextFiled: QMUITextField = {
        let tf = createTf("请输入用户名")
        tf.keyboardType = .asciiCapable
        return tf
    }()
    
    lazy var passwordTextFiled: QMUITextField = {
        let tf = createTf("请输入密码")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var loginButton: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle("登录", for: .normal)
        btn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var configButton: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle("配置", for: .normal)
        btn.addTarget(self, action: #selector(baseConfigAction), for: .touchUpInside)
        return btn
    }()
    
    
    private func createTf(_ placeHoldel: String) -> QMUITextField{
        let tf = QMUITextField()
        tf.placeholder = placeHoldel
        tf.clearButtonMode = .whileEditing
        return tf
    }
    
    lazy var tipView: QMUITips = {
        let tipView = QMUITips(view: view)
        return tipView
    }()
    
}

extension LoginVC {
    
    @objc private func loginAction() {
        let tempEnv = 2
        if tempEnv == 0 {
            apiServer = "http://10.91.1.23:8080"
            env = .develop
        } else if tempEnv == 1 {
            apiServer = "https://rtc-dev.rokid.com"
            env = .develop
        } else if tempEnv == 2 {
            apiServer = "https://rtc-test.rokid.com"
            env = .test
        } else {
            apiServer = "https://rtc.rokid.com"
            env = .test
        }
        
        RKLogMgr.shared.logLevel = .verbose
        RKCooperationCore.shared.initWith(appId: appId, apiServer: apiServer, onSuccess: nil, onFailed: nil)
        RKCooperationCore.shared.addLogin(listener: self)
        guard let company = companyTextFiled.text, !company.isEmpty else {
            QMUITips.showError("公司名不能为空")
            return
        }
        guard let userId = userTextFiled.text, !userId.isEmpty else {
            QMUITips.showError("用户名不能为空")
            return
        }
        guard let passwordId = passwordTextFiled.text, !passwordId.isEmpty else {
            QMUITips.showError("密码名不能为空")
            return
        }
        
        UserDefaults.standard.setValue(company, forKey: RKLoginUDKeys.companyIdKey)
        UserDefaults.standard.setValue(userId, forKey: RKLoginUDKeys.userNameKey)
        UserDefaults.standard.setValue(passwordId, forKey: RKLoginUDKeys.passwordKey)
        UserDefaults.standard.synchronize()
        
        tipView.showLoading("登录中")
        LoginHelper.loginAction(companyID: company, userName: userId, password: passwordId) { uid, token, refeshToken, expirTime, errorMsg  in
            self.tipView.hide(animated: true)
            self.tipView.removeFromSuperview()
            if let errorMsg = errorMsg {
                QMUITips.showError(errorMsg)
            }
            guard let token = token else { return }
            
            ContactManager.shared.refreshToken = refeshToken
            
            LoginHelper.getUserInfo(token) { dict, isSucess in
                guard isSucess == true,
                      let uesrInfo = RKUser.deserialize(from: dict) else {
                    QMUITips.showSucceed("登录失败")
                    return
                }
                ContactManager.shared.userInfo.userId = uesrInfo.userId
                RKCooperationCore.shared.login(with: uesrInfo.userId)
                QMUITips.showSucceed("登录成功")
            }
        }
    }
    
    @objc func baseConfigAction() {
        let placeholderAndTexts = [("appId", appId), ("apiServer", apiServer)]
        let alertVC = RKAlertController.alertInputViews(title: "请输入配置信息",
                                                        message: nil,
                                                        placeholderAndTexts: placeholderAndTexts) { text in
            guard let appId = text.first,
                  let apiServer = text.last else {
                QMUITips.showSucceed("频道ID不能为空！")
                return
            }
            
            self.appId = appId
            self.apiServer = apiServer
            RKCooperationCore.shared.initWith(appId: self.appId, apiServer: self.apiServer, onSuccess: nil, onFailed: nil)
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func loginSucc() {
        let mainVC = ContactListVC()
        mainVC.loadData()
        self.navigationController?.pushViewController(mainVC, animated: true)
        loginQueryBlock?()
        loginQueryBlock = nil
    }
    
    
}

extension LoginVC: RKLoginCallback {
    
    
    func onLogin(reason: RKCooperationCode) {
        tipView.hide(animated: true)
        tipView.removeFromSuperview()
        if reason == .OK {
            QMUITips.showSucceed("登录成功")
            self.loginSucc()
        } else {
            QMUITips.showError("登录失败 code \(reason.rawValue)")
        }
        
    }
    
    func onLogout(reason: RKCooperationCode) {
        RKCooperationCore.shared.logout()
        self.navigationController?.popToViewController(self, animated: false)
    }
    
    func onJoinedChannelList(_ channelList: [RKIJoinedChannel]?) {
        guard let channelList = channelList, channelList.isEmpty == false else {
            return
        }
        
        var channelIdString: String = ""
        channelList.forEach { iJoinedChannel in
            channelIdString += iJoinedChannel.channelId
            channelIdString += "\n"
        }
        let alertVC = RKAlertController.alertAlert(title: "当前用户已经在会议中",
                                                   message: channelIdString,
                                                   okTitle: "全部离开") {
            channelList.forEach { iJoinedChannel in
                RKChannelManager.shared.leave(channelId: iJoinedChannel.channelId)
            }
        }
        
        loginQueryBlock = { [weak self] in
            self?.present(alertVC, animated: true, completion: nil)
        }
        
    }
}


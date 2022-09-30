//
//  DemoLoginHelper.swift
//  RKCooperDemo
//
//  Created by chzy on 2022/9/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import RKIHandyJSON

class DemoApiRespond: NSObject, HandyJSON {
    var code: Int = 0
    var message: String = "failed"
    var data: Any?
    required override init() {}
}

typealias DemoApiRespondBlock = ( _ responsed: DemoApiRespond) -> Void

class DemoApiHelper {
    
    static var apiHost = ""
    static var companyIndex = "rokid"
    class func addUserName(companyIndex: String, userName: String, compeletHandle: @escaping DemoApiRespondBlock) {
        var param: [String: String] = [:]
        param["companyIndex"] = companyIndex
        param["userName"] = userName
        baseRequest(method: .post, reqString: "/cooperate/addUserName", param: param, compelethandle: compeletHandle)
    }
    
    class func canLogin(companyIndex: String = "rokid", userName: String, compeletHandle: @escaping DemoApiRespondBlock) {
        var param: [String: String] = [:]
        param["companyIndex"] = companyIndex
        param["userName"] = userName
        baseRequest(method: .get, reqString: "/cooperate/login", param: param, compelethandle: compeletHandle)
    }
    
    class func getUserList(companyIndex: String = "rokid", compeletHandle: @escaping DemoApiRespondBlock) {
        var param: [String: String] = [:]
        param["companyIndex"] = companyIndex
        baseRequest(method: .get, reqString: "/cooperate/getUserList", param: param, compelethandle: compeletHandle)
    }
    
    private class func baseRequest(method: HTTPMethod, reqString: String, param: [String: Any], compelethandle: @escaping DemoApiRespondBlock) {
        let url = apiHost + reqString
        var encoding :ParameterEncoding = JSONEncoding.default
        if method == .get {
            encoding = URLEncoding.default
        }
        let req = AF.request(url, method: method, parameters: param, encoding: encoding)
        req.responseString { res in
          if let res = res.value {
                let model = JSONDeserializer<DemoApiRespond>.deserializeFrom(json: res)!
                compelethandle(model)
            }
            else {
                compelethandle(DemoApiRespond())
            }
           
        }
   
    }
    
}

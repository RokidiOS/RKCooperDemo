//
//  RKRoomMember.swift
//  RokidExpert
//
//  Created by Rokid on 2021/12/24.
//

import Foundation
import RKCooperationCore


class RKRoomMember {
        
    var participant: RKChannelParticipant? // 成员的频道信息
    
    var userId: String = ""
    
    var userName: String = ""
    
    var state: String?
    
    // 是否暂停了视频流
    var isStopVideo: Bool = false
    
    
    ///当前是否是自己
    func isSelf() ->Bool {
        return participant?.isSelf ?? false
    }
}

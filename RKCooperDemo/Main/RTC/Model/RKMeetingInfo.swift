//
//  MeetingInfo.swift
//  iOSRokid
//
//

import RKIHandyJSON

class RKMeetingInfo: NSObject, HandyJSON {
    // 会议频道ID
    public var channelId: String = "" {
        didSet {
            if !channelId.isEmpty,
               meetingId.isEmpty {
                meetingId = channelId
            }
        }
    }
    public var channelname: String = ""     // 频道名字
    public var channelPassword: String = "" // 频道密码
    // 会议ID
    public var meetingId: String = "" {
        didSet {
            if !meetingId.isEmpty,
               channelId.isEmpty {
                channelId = meetingId
            }
        }
    }
    public var name: String = ""            // 房间名字
    public var startTime: Int64 = 0
    public var resolutionRatio: String = ""
    
    public var fromUserId: String = ""    // 发起人Id
    
    public var serverId        = "" // 群聊id
    public var oneStreamUserId  = "" // 单流视频id

    public func mapping(mapper: HelpingMapper) {
        mapper <<<
            meetingId <-- "id"
    }
    
    required public override init() {}
    
}

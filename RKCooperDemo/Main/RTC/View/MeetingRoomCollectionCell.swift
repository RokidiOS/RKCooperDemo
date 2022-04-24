//
//  RKMeetingRoomCollectionCell.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/20.
//

import UIKit
import RKIUtils

class MeetingRoomCollectionCell: UICollectionViewCell {
    // 画面视图
    var videoView: UIView!
    // 状态视图
    var stateView: UIView!
    // 摄像视图内容
    var stateImageView: UIImageView!
    var stateLabel: UILabel!
    // 用户名
    var userNameLabel: UILabel!
    // 语音图标
    var voiceImageView: UIImageView!
    
    var rtcInfoLabel: UILabel!
    
    var info: RKRoomMember?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        videoView = UIView.init()
        videoView.clipsToBounds = true
        self.contentView.addSubview(videoView)
        stateView = UIView.init()
        stateView.backgroundColor = RKColor.roomCellBgClr
        self.contentView.addSubview(stateView)
        
        stateImageView = UIImageView.init()
        stateImageView.contentMode = .scaleAspectFit
        stateImageView.image = UIImage(named: "ic_call_room_member_detail_camera",
                                       in: Bundle(for: self.classForCoder),
                                       compatibleWith: nil)
        stateView.addSubview(stateImageView)
        
        stateLabel = UILabel.init()
        stateLabel.font = UIFont.systemFont(ofSize: 18)
        stateLabel.textColor = .white
        stateLabel.textAlignment = .center
        stateView.addSubview(stateLabel)
        
        userNameLabel = UILabel.init()
        userNameLabel.font = UIFont.systemFont(ofSize: 13)
        userNameLabel.textColor = .white
        self.contentView.addSubview(userNameLabel)
        
        rtcInfoLabel = UILabel.init()
        rtcInfoLabel.font = userNameLabel.font
        rtcInfoLabel.textColor = .white
        rtcInfoLabel.numberOfLines = 0
        rtcInfoLabel.setContentHuggingPriority(.required, for: .vertical)
        self.contentView.addSubview(rtcInfoLabel)
        
        voiceImageView = UIImageView.init()
        voiceImageView.image = UIImage(named: "ic_call_room_member_mic_on",
                                       in: Bundle(for: self.classForCoder),
                                       compatibleWith: nil)
        self.contentView.addSubview(voiceImageView)
        
        userNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(10)
            make.height.equalTo(22)
            make.right.equalTo(voiceImageView)
        }
        
        rtcInfoLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(userNameLabel.snp.top)
        }
        
        voiceImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(userNameLabel)
            make.width.height.equalTo(20)
        }
        
        videoView.snp.makeConstraints { (make) in
            make.top.left.width.height.equalToSuperview()
        }
        
        stateView.snp.makeConstraints { (make) in
            make.top.left.width.height.equalToSuperview()
        }
        
        stateImageView.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        stateLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

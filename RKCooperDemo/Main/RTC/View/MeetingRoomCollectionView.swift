//
//  RKMeetingRoomCollectionView.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/19.
//  会议页面 宫格collectionView

import UIKit
import RKIUtils
import RKCooperationCore
import RKRTC

protocol MeetingRoomCollectionViewDelegate: NSObjectProtocol {
    // MARK: - 点击单个视频回调
    func didSelectItemAt(_ memberView: RKRoomMember, cell: MeetingRoomCollectionCell)
}

// 视频信息 hight 大流信息； low 小流信息； loas丢包信息
struct VideoInfo {
    var hight: String = ""
    var low: String = ""
    var loss: String = ""
}

class MeetingRoomCollectionView: UIView {
    
    weak var collectionView: UICollectionView!
    
    weak var delegate: MeetingRoomCollectionViewDelegate?
    
    var meetingMembers = [RKRoomMember]()
    
    // userid : (l,h, lossRate)
    var videoInfos = [String: VideoInfo]()
    
    deinit {
        print("MeetingRoomCollectionView dealloc")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()  {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.backgroundColor = RKColor.BgColor
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        self.addSubview(collectionView)
        self.collectionView = collectionView
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.width.height.equalTo(self)
        }
    }
    
    func updateCell(userId: String, lossRate: Float) {
        var newInfoString = "lossRate: \(lossRate * 100)/100"
        newInfoString = fillInfoData(userId: userId, newInfoString: newInfoString) { info in
            info.loss = newInfoString
        }
        _ = collectionView.visibleCells.first { cell in
            guard let cell = cell as? MeetingRoomCollectionCell else { return false }
            if cell.info?.userId == userId {
                cell.rtcInfoLabel.text = newInfoString
                return true
            }
            return false
        }
    }
    
    func updateAudioCell(_ userId: String, bitrate: Int32)  {
        _ = collectionView.visibleCells.first { cell in
            guard let cell = cell as? MeetingRoomCollectionCell else { return false }
            if cell.info?.userId == userId {
                cell.audioInfoLabel.text = "audio \(bitrate) Kpbs"
                return true
            }
            return false
        }
    }
    
    func updateCell(userId: String, width: Int32, height: Int32, fps: Int32, rid: String, bitrate: Int32, qualityLimitationReason: String?, packetsLost: Int32? = nil) -> String{
        
        var newInfoString = ""
        
        if rid.isEmpty == false {
            newInfoString.append(" rid: \(rid) ")
        }
        
        newInfoString.append("w: \(width) h: \(height) fps: \(fps) br: \(bitrate) Kbps")
        
        if let qualityLimitationReason = qualityLimitationReason {
            newInfoString.append(" qR:\(qualityLimitationReason)")
        }
        
        if let packetsLost = packetsLost {
            newInfoString.append(" plost \(packetsLost)")
        }
        
        newInfoString = fillInfoData(userId: userId, newInfoString: newInfoString) { info in
            if rid == "l" {
                info.low = newInfoString
            } else {
                info.hight = newInfoString
            }
        }
        
        _ = collectionView.visibleCells.first { cell in
            guard let cell = cell as? MeetingRoomCollectionCell else { return false }
            if cell.info?.userId == userId {
                cell.rtcInfoLabel.text = newInfoString
                return true
            }
            return false
        }
        return newInfoString
    }
    
    private func fillInfoData(userId: String, newInfoString: String, tmBlock: @escaping (inout VideoInfo) -> Void) ->String {
        if var info = videoInfos[userId] {
            tmBlock(&info)
            videoInfos[userId] = info
            return info.low + "\n" + info.hight + "\n" + info.loss
        } else {
            var info = VideoInfo()
            tmBlock(&info)
            videoInfos[userId] = info
            return info.low + "\n" + info.hight + "\n" + info.loss
        }
        
    }
}

extension MeetingRoomCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meetingMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ide = NSStringFromClass(MeetingRoomCollectionCell.self) + "\(indexPath.row)"
        collectionView.register(MeetingRoomCollectionCell.self, forCellWithReuseIdentifier: ide)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ide, for: indexPath) as! MeetingRoomCollectionCell
        let roomMember = meetingMembers[indexPath.row]
        cell.info = roomMember
        if let tuple = videoInfos[roomMember.userId] {
            cell.rtcInfoLabel.text = tuple.low + tuple.hight + tuple.loss
        }
        cell.userNameLabel.text = kcontactList.first(where: { model in
            model.userId == roomMember.userId
        })?.realName ?? "我"
        
        if roomMember.participant?.isAudioStart == false {
            cell.voiceImageView.image = UIImage(named: "ic_call_room_member_mic_off", in:  Bundle(for: self.classForCoder), compatibleWith: nil)
        } else {
            cell.voiceImageView.image = UIImage(named: "ic_call_room_member_mic_on", in:  Bundle(for: self.classForCoder), compatibleWith: nil)
        }
        guard let channel = MeetingManager.shared.channel else { return cell}
        // 不是自己在做屏幕共享
        let showScreenFlag: Bool = channel.shareInfo?.shareType == .screen &&  channel.shareInfo?.promoterUserId == roomMember.participant?.userId
        let showDoodleFlag: Bool = channel.shareInfo?.shareType == .doodle
        let showFlag = (showScreenFlag && roomMember.participant?.userId == RKUserManager.shared.userId) || showDoodleFlag
        if roomMember.state?.isEmpty == false, showFlag {
            // 状态展示
            cell.videoView.isHidden = true
            cell.stateImageView.isHidden = true
            cell.stateView.isHidden = false
            cell.stateLabel.isHidden = false
            cell.stateLabel.text = roomMember.state
        } else if let participant = roomMember.participant,
                  (participant.isVideoStart == true || showScreenFlag){
            // 视频流赋值
            participant.startVideo(renderType: .RENDER_FULL_SCREEN, videoSize:.SIZE_LARGE) { [weak cell]  canvas in
                if let canvasView = canvas?.videoView {
                    cell?.videoView.addSubview(canvasView)
                    canvasView.snp.remakeConstraints { (make) in
                        make.top.left.width.height.equalToSuperview()
                    }
                }
            }
            cell.videoView.isHidden = false
            cell.stateView.isHidden = true
            cell.stateImageView.isHidden = true
            cell.stateLabel.isHidden = true
            cell.stateLabel.text = nil
            #warning("TODO iOS 12 会存在一个上下旋转问题")
//            guard let osSubstring = UIDevice.current.systemVersion.split(separator: ".").first else {
//                return cell
//            }
//
//            let versionString = String(osSubstring)
//            if versionString == "13" {
//                if MeetingManager.shared.currentBackCamera == false {
//                    cell.videoView.transform = CGAffineTransform(scaleX: -1.0, y: -1.0)
//                } else {
//                    cell.videoView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                }
//            }
            
        }
        else {
            cell.videoView.isHidden = true
            cell.stateView.isHidden = false
            cell.stateImageView.isHidden = false
            cell.stateLabel.isHidden = true
            cell.stateLabel.text = nil
        }
        
        return cell
    }
}

extension MeetingRoomCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? MeetingRoomCollectionCell {
            delegate?.didSelectItemAt(meetingMembers[indexPath.row], cell: cell)
        }
    }
}

extension MeetingRoomCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 6
        let height = collectionView.frame.height / 2 - 6
        return CGSize(width: width, height: height)
    }
    
}

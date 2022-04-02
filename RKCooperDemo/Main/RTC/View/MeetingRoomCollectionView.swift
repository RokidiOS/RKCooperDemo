//
//  RKMeetingRoomCollectionView.swift
//  RokidSDK
//
//  Created by Rokid on 2021/7/19.
//

import UIKit
import RKIUtils

protocol MeetingRoomCollectionViewDelegate: NSObjectProtocol {
    // MARK: - 点击单个视频回调
    func didSelectItemAt(_ memberView: RKRoomMember, cell: MeetingRoomCollectionCell)
}


class MeetingRoomCollectionView: UIView {
    
    weak var collectionView: UICollectionView!
    
    weak var delegate: MeetingRoomCollectionViewDelegate?
    
    var meetingMembers = [RKRoomMember]()
    
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
        
        collectionView.register(MeetingRoomCollectionCell.self, forCellWithReuseIdentifier: NSStringFromClass(MeetingRoomCollectionCell.self))
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
}

extension MeetingRoomCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meetingMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MeetingRoomCollectionCell.self), for: indexPath) as! MeetingRoomCollectionCell
        let roomMember = meetingMembers[indexPath.row]
        cell.userNameLabel.text = kcontactList.first(where: { model in
            model.userId == roomMember.userId
        })?.realName ?? "我"
        
        if roomMember.participant?.isAudioStart == false {
            cell.voiceImageView.image = UIImage(named: "ic_call_room_member_mic_off", in:  Bundle(for: self.classForCoder), compatibleWith: nil)
        } else {
            cell.voiceImageView.image = UIImage(named: "ic_call_room_member_mic_on", in:  Bundle(for: self.classForCoder), compatibleWith: nil)
        }
        if roomMember.state?.isEmpty == false {
            // 状态展示
            cell.videoView.isHidden = true
            cell.stateImageView.isHidden = true
            cell.stateView.isHidden = false
            cell.stateLabel.isHidden = false
            cell.stateLabel.text = roomMember.state
        } else if let participant = roomMember.participant,
                  participant.isVideoStart == true {
            participant.startVideo(renderType: .RENDER_FULL_SCREEN, videoSize:.SIZE_LARGE) { canvas in
                if let canvasView = canvas?.videoView {
                    cell.videoView.addSubview(canvasView)
                    canvasView.snp.remakeConstraints { (make) in
                        make.top.left.width.height.equalToSuperview()
                    }
                    roomMember.participant?.videoCanvas = canvas
                }
            }
            cell.videoView.isHidden = false
            cell.stateView.isHidden = true
            cell.stateImageView.isHidden = true
            cell.stateLabel.isHidden = true
            cell.stateLabel.text = nil
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

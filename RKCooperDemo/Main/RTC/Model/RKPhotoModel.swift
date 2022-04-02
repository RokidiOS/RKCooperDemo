//
//  RKPhotoModel.swift
//  RokidSDK
//
//  Created by Rokid on 2021/8/10.
//

import UIKit
import Photos

let RKMaxImageWidth: CGFloat = 600

extension RKPhotoModel {
    
    public enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
    
}


public class RKPhotoModel: NSObject {

    public let ident: String
    
    public let asset: PHAsset
    
    public var type: RKPhotoModel.MediaType = .unknown
    
    public var duration: String = ""
    
    public var isSelected: Bool = false
        
    public var second: Int {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    public var whRatio: CGFloat {
        return CGFloat(self.asset.pixelWidth) / CGFloat(self.asset.pixelHeight)
    }
    
    public var previewSize: CGSize {
        let scale: CGFloat = 2 //UIScreen.main.scale
        if self.whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, RKMaxImageWidth) * scale
            let w = h * self.whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, RKMaxImageWidth) * scale
            let h = w / self.whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    public init(asset: PHAsset) {
        self.ident = asset.localIdentifier
        self.asset = asset
        super.init()
        
        self.type = self.transformAssetType(for: asset)
        if self.type == .video {
            self.duration = self.transformDuration(for: asset)
        }
    }
    
    public func transformAssetType(for asset: PHAsset) -> RKPhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if #available(iOS 9.1, *) {
                if asset.mediaSubtypes == .photoLive || asset.mediaSubtypes.rawValue == 10 {
                    return .livePhoto
                }
            }
            return .image
        default:
            return .unknown
        }
    }
    
    public func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
}

public func ==(lhs: RKPhotoModel, rhs: RKPhotoModel) -> Bool {
    return lhs.ident == rhs.ident
}


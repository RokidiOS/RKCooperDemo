//
//  RKExt.swift
//  RokidExpert
//
//  Created by Rokid on 2021/12/22.
//

import Foundation
import UIKit
import Photos

func currentVersion(point: Bool) -> String {
    
    let ver: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    if point {
        return ver
    }
    let verArray = ver.components(separatedBy: ".")
    var verString = ""
    for str in verArray {
        verString = verString.appending(str)
    }
    return verString
}

func generateQRCode(_ qrStr: String) -> UIImage? {
    
    let data = qrStr.data(using: String.Encoding.ascii)
    
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    
    filter.setValue(data, forKey: "inputMessage")
    
    let transform = CGAffineTransform(scaleX: 9, y: 9)
    
    guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
    
    return UIImage(ciImage: output)
}

extension UIView {
    func addSubViews(_ array: [UIView]) {
        for view in array {
            addSubview(view)
        }
    }
    
    func removeSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
}

extension UIImage {
    func saveImageToPhotoLibrary(_ compeleBlock: @escaping (Bool) -> Void) {
        // 判断权限
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            saveImage(compeleBlock)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                if status == .authorized {
                    self?.saveImage(compeleBlock)
                } else {
                    print("User denied")
                    compeleBlock(false)
                }
            }
            
        case .restricted, .denied:
            if let url = URL.init(string: UIApplicationOpenSettingsURLString) {
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
                compeleBlock(false)
            }
            
        default: print("")
            compeleBlock(false)
        }
    }
    
    func saveImage(_ compeleBlock: @escaping (Bool) -> Void) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: self)
        }, completionHandler: { (isSuccess, _) in
            DispatchQueue.main.async {
                compeleBlock(isSuccess)
            }
        })
    }
    
    public func tintColor(_ color :UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect.init(x:0, y:0, width:self.size.width, height:self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode:CGBlendMode.destinationIn, alpha:1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
}

extension String {
    
    static func formatTalkingTime(_ timeInterval: Int64) -> String {
        if timeInterval > 3600 {
            let hour: Int64 = timeInterval / 3600
            let hourValue = hour > 9 ? "\(hour)": "0\(hour)"
            let minute: Int64 = timeInterval % 3600 / 60
            let minuteValue = minute > 9 ? "\(minute)": "0\(minute)"
            let seconds: Int64 = timeInterval % 60
            let secondsValue = seconds > 9 ? "\(seconds)": "0\(seconds)"
            return String.init("\(hourValue):\(minuteValue):\(secondsValue)")
        } else {
            let minute: Int64 = timeInterval / 60
            let minuteValue = minute > 9 ? "\(minute)": "0\(minute)"
            let seconds: Int64 = timeInterval % 60
            let secondsValue = seconds > 9 ? "\(seconds)": "0\(seconds)"
            return String.init("00:\(minuteValue):\(secondsValue)")
        }
    }
    
    static func tempSnapshotFilePath(fileName: String) -> String {
        
        let dirPath = NSHomeDirectory() + "/Documents/tmp_snapshot"
        if FileManager.default.fileExists(atPath: dirPath) == false {
            do {
                try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                
            }
        }
        
        let snapshotPath = dirPath + "/" + fileName
        do {
            try FileManager.default.removeItem(atPath: snapshotPath)
        } catch _ {
            
        }
        
        return snapshotPath
    }
    
}


class TempTool : NSObject {
   
    // 强制旋转横屏
    static func forceOrientationLandscape() {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.rotation = .landscape
        let oriention = UIInterfaceOrientation.landscapeRight // 设置屏幕为横屏
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    // 强制旋转竖屏
    static func forceOrientationPortrait() {
        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.rotation = .all
        let oriention = UIInterfaceOrientation.portrait // 设置屏幕为竖屏
        UIDevice.current.setValue(oriention.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

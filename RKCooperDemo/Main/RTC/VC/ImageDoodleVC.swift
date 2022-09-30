//
//  ImageDoodleVC.swift
//  RKCooperDemo
//
//  Created by chzy on 2022/9/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

class ImageDoodleVC: DoodleVC {
    
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(drawView)
        }
        view.sendSubview(toBack: imageView)
        
    }
    public func setUlr(_ url: String?) {
        guard let url = url, let imgUrl = URL(string: url) else {
            return
        }
        self.imageView.kf.setImage(with: imgUrl)
    }
    
}

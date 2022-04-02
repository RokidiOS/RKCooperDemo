//
//  RKMaskView.swift
//  RokidExpert
//
//  Created by Rokid on 2021/12/20.
//

import UIKit

class RKMaskView: UIView {
    
    let maskTag = 9999
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()  {
        
        self.tag = maskTag
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.7)
    }
    
    @objc func calcenMaskView() {
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first,
           let view = touch.view,
           view.tag == maskTag {
            // 点击空白区域移除
            self.removeFromSuperview()
        }
    }
}

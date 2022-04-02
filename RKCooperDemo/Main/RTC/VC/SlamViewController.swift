//
//  SlamViewController.swift
//  RKCooperDemo
//
//  Created by chzy on 2022/3/30.
//  Copyright © 2022 CocoaPods. All rights reserved.
//  arkit视频流上传 demoVC TODO

import UIKit
import ARKit
import RKCooperationCore

@available(iOS 11.0, *)
class SlamViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView?
    var gpuLoop: CADisplayLink?
    override func viewDidLoad() {
        super.viewDidLoad()
        configARKit()
        guard let sceneView = sceneView else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        /// 暂时ar debug信息
        //        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showPhysicsFields]
        sceneView.session.run(configuration)

    }
    
    func configARKit() {
        
        let tpSceneView = ARSCNView(frame: view.bounds)
        view.addSubview(tpSceneView)
        tpSceneView.session.delegate = self
        tpSceneView.delegate = self
        sceneView = tpSceneView
        RKDevice.startVideoFile()
        gpuLoop = CADisplayLink(target: self,
                                selector: #selector(updateArData))
        gpuLoop?.preferredFramesPerSecond = 20
        gpuLoop?.add(to: .main, forMode: .defaultRunLoopMode)
        
        
    }

    @objc private func updateArData() {
        DispatchQueue.global().sync {
            if let buff = self.sceneView?.session.currentFrame?.capturedImage {
                RKDevice.setVideoFileFrame(buff, rotation: .VideoRotation_0)
            }
        }
    }
}


@available(iOS 11.0, *)
extension SlamViewController: ARSessionDelegate {
    
    /// 当frame更新时
    static var idex = 1
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        CVPixelBufferGetPixelFormatType(frame.capturedImage)
    }
    
    /// 当一个新被添加到当前session时node
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        guard anchors[0] is ARPlaneAnchor else {
            return
        }
        
    }
    
    /// 当node更新时
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    ///当node被移除时
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    
}


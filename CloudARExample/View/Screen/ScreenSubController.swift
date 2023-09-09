//
//  ScreenSubController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import CloudAR

class ScreenSubController: UIViewController
{
    var screenSubView: ScreenSubView!
    
    override func loadView() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        screenSubView = ScreenSubView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        screenSubView.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.view = screenSubView
        view.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerGesture()
    }
    
    private func registerGesture() {
        // 点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        // 拖动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(panGesture)
        
        print("register gesture in screen sub controller")
    }
    //MARK: Gesture
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: self.view)
            car_sendClickGesture(point: point, size: self.view.bounds.size) { result in }
        }
        
    }
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let state = sender.state == .began ? car_InputState.began : sender.state == .changed ? .changed : .ended
        car_sendPanGesture(point: translation, size: view.frame.size,state: state, completion: {_ in })
    }
    
    //MARK: 监听场景模式切换
    func listenSwitchScreenMode(toScreenMode: CloudAR.car_ScreenMode) {
        // threeD <---> ar btn
        screenSubView?.switchModeView?.changeSwitchBG(toScreenMode: toScreenMode)
        
        screenSubView?.enterPositionBtn?.isHidden = toScreenMode != .AR
    }
}

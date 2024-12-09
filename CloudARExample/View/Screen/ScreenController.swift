//
//  ScreenController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import CloudAR

class ScreenController: UIViewController
,ARPositionProtocol //ar定位代理
,CloudXRConnectProtocol //cloudxr连接代理
,EnterPositionPtocotol //进入定位
,ModelLoadFinishProtocol //场景
,CloudXRClientStateUpdateProtocol //cloudxr客户端状态更新代理
{
    func notifyServerDisConnect() {
        
    }
    
    func notifyConnectQualityState(quality: CloudAR.car_StreamQuality, reason: CloudAR.car_StreamQualityReason) {
    }
    func notifyConnectQualityState() {
    }
    func notifyLatchFrameError() {
    }
    
    var screenSubController: ScreenSubController!
    var loadController: LoadController! //模型加载
    //AR
    var arScreenController: ARModelController! //ar相关控制器
    var arConnectStatsTimer: Timer? //ar连接状态定时器
    //ThreeD
    var threeDScreenController: ThreeDScreenController! //threeD相关
    
    var isInSwitchModel : Bool = false
    
    override func viewDidLoad() {
        
        self.view.isUserInteractionEnabled = true
        self.view = ScreenView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.backgroundColor  = .white
        
        screenSubController = ScreenSubController()
        screenSubController.view.isUserInteractionEnabled = true
        addChild(screenSubController)
        self.view.insertSubview(screenSubController.view, at: 1)
        screenSubController!.didMove(toParent: self)
        screenSubController!.view.backgroundColor = UIColor(white: 1, alpha: 0)
        
        loadController = LoadController()
        loadController.modelLoadFinishProtocol = self
        addChild(loadController)
        self.view.insertSubview(loadController.view, at: 2)
        loadController!.didMove(toParent: self)
        
        screenSubController?.screenSubView?.exitScreenBtn?.btn?.addAction(UIAction(handler: {_ in
            self.handleScreenExit()
        }), for: .touchUpInside)
        
        screenSubController?.screenSubView?.switchModeView?.btnSwitch?.addAction(UIAction(handler: {_ in
            if (!self.isInSwitchModel)
            {
                self.handleSwitchScreenMode(toScreenMode: car_EngineStatus.screenMode == .AR ? .ThreeD : .AR)
            }
        }), for: .touchUpInside)
        
        screenSubController?.screenSubView?.enterPositionBtn?.btn?.addAction(UIAction(handler: {_ in
            self.handleEnterPosition()
        }), for: .touchUpInside)
        
        loadController?.modelLoadView?.backBtn?.btn?.addAction(UIAction(handler: {_ in
            self.handleScreenExit()
        }), for: .touchUpInside)
    }
    
    //MARK: ARPositionProtocol
    func handleConfirmPosition(type: CloudAR.car_ARPositionType) {
        switch type {
        case .None:
            break
        case .ScanPosition:
            screenSubController!.view.isHidden = false
        case .SpacePosition:
            break
        @unknown default:
            break
        }
    }
    func handleCanclePosition() {
        screenSubController!.view.isHidden = false
        screenSubController!.view.isUserInteractionEnabled = true
    }
    
    //MARK: CloudXRConnectProtocol
    // 首次连接时的反馈
    func notifyConnect(connected: Bool) {
        if connected {
            loadController!.queryLoadModel()
        } else {
            //cloudxr如果没有连接成功，需要立即删除arModelController
            arScreenController?.removeFromParent()
            arScreenController = nil
            handleModelLoadFinish(isSuccess: false, reason: "cloudxr连接失败", screenType: .AR, project: "")
        }
    }
    // MARK: CloudXRConnectProtocol reconnect
    // 重连时的反馈
    func notifyReconnect(connected: Bool) {
        //TODO:
    }
    //MARK: ModelLoadFinishProtocol
    func handleModelLoadFinish(isSuccess: Bool, reason: String, screenType: CloudAR.car_ScreenMode, project: String) {
        if isSuccess {
            print("模型启动成功")
            // 记录场景模式和项目id
            car_EngineStatus.screenMode = screenType
            car_UserInfo.currProID = project
            
            screenSubController!.view.isHidden = false
            loadController!.view.isHidden = true

            screenType == .AR ? printConnectStats() : ()
            
            screenSubController.listenSwitchScreenMode(toScreenMode: screenType)
            
        } else {
            print("模型启动失败")
            showTip(tip: reason, parentView: self.view, false) {
                // 退出场景
                self.handleScreenExit()
            }
        }
    }
    //MARK: EnterPositionPtocotol
    func handleEnterPosition() {
        screenSubController!.view.isHidden = true
        car_EngineStatus.arPositionType = .ScanPosition //切换screenmode后默认是扫码定位
        arScreenController?.enterPosition(positionType: car_EngineStatus.arPositionType)
    }
    
    //MARK: SwitchScreenModeProtocol
    func handleSwitchScreenMode(toScreenMode: CloudAR.car_ScreenMode) {
        
        if (isInSwitchModel)
        {
            showTip(tip: "已经在切换中", parentView: self.view, false, completion: {})
        } else {
            isInSwitchModel = true
            // 退出当前模式的场景
            sendModelQuit(screenType: toScreenMode == .AR ? .ThreeD : .AR)
            
            // 如果是切换到ar模式下，需要重启steamvr，然后再loadModel
            if (toScreenMode == .AR)
            {
                // 不重启steamvr，对连接cloud服务会有一定的影响
                restartSteamvr(completion: {success,reason in })
                // 加载新模式的模型: 这里延迟是为了等待stemvr的重启，这个等待会造成 UI切换 不流畅（可以根据自定义切换ui来解决）
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
                    self.loadModel(projectID: car_UserInfo.currProID, screenType: toScreenMode) //同一模型用另一种方式打开，所以projectID不变
                    self.isInSwitchModel = false
                }
            } else {
                self.loadModel(projectID: car_UserInfo.currProID, screenType: toScreenMode) //同一模型用另一种方式打开，所以projectID不变
                isInSwitchModel = false
            }
        }
    }
    
    //MARK: CloudXRClientStateUpdateProtocol
    func notifyClientStateUpdate(state: car_ClientState, reason: car_ClientStateReason) {
        if (state == .disconnected)
        {
            // 创建一个弹窗：显示是否重连
            var disConnectAlert = UIAlertController(title: "提示", message: "服务断开", preferredStyle: .alert)
            
            disConnectAlert.addAction(UIAlertAction(title: "退出", style: .cancel){_ in })
            
            disConnectAlert.addAction(UIAlertAction(title: "重连", style: .default) { _ in
                self.reconnectCloudxr()
            })
            
            present(disConnectAlert, animated: true)
        }
    }
    
    //MARK: 打印CloudXR连接状态 只有ar模式有效
    private func printConnectStats() {
        // 定时器时间间隔应 > 2s
        arConnectStatsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
            if car_EngineStatus.screenMode == .AR {
                let (isSuccess,quality,reason) = self.arScreenController!.getConnectQuality()
                print("success:\(isSuccess),quality: \(String(describing: quality)),reason: \(String(describing: reason))")
            } else {
                timer.invalidate()
            }
        }
        arConnectStatsTimer?.fire()
    }
    
    //MARK: 通过此函数来开始请求加载模型一些相关工作
    func loadModel(projectID: String,screenType: car_ScreenMode) {
        WebSocketClient.shared.close() //断开与java的websocket
        WebSocketClient.shared.socketProtocol = loadController!
        
        self.arConnectStatsTimer?.invalidate()
        
        car_EngineStatus.screenMode = screenType
        screenSubController!.view.isHidden = true
        loadController!.loadInfo = (projectID,screenType)
        loadController!.view.isHidden = false
        
        // ar相关的清除
        arScreenController?.removeFromParent()
        arScreenController?.view?.removeFromSuperview()
        arScreenController = nil
        // threeD相关的清楚
        threeDScreenController?.removeFromParent()
        threeDScreenController?.view?.removeFromSuperview()
        threeDScreenController = nil
        
        switch screenType {
        case .AR:
            arScreenController = ARModelController()
            arScreenController!.notityConnectProtocol = self
            arScreenController!.arPositionProtocol = self
            addChild(arScreenController!)
            view.insertSubview(arScreenController!.view, at: 0)
            arScreenController!.didMove(toParent: self)
            break
        case .ThreeD:
            // threeD嵌入在ScreenSubControll中作为subview
            threeDScreenController = ThreeDScreenController()
            screenSubController.addChild(threeDScreenController!)
            screenSubController.view.insertSubview(threeDScreenController!.view, at: 0)
            threeDScreenController!.didMove(toParent: screenSubController)
            screenSubController!.view.isHidden = false
            loadController!.loadThreeDURLProcotol = threeDScreenController
            loadController!.queryLoadModel()
            break
        case .None:
            break
        @unknown default:
            break
        }
    }
    
    private func handleScreenExit() {
        loadController?.removeFromParent()
        arScreenController?.removeFromParent()
        screenSubController?.removeFromParent()
        threeDScreenController?.removeFromParent()
        
        sendModelQuit(screenType: car_EngineStatus.screenMode)
        
        car_UserInfo.currProID = ""
        car_UserInfo.taskID = ""
        
        if car_EngineStatus.screenMode == .AR {
            car_EngineStatus.lastExitARTime = Date().timeStamp //记录退出时间
        }
        car_EngineStatus.screenMode = .None
        
        WebSocketClient.shared.close()
        
        self.arConnectStatsTimer?.invalidate()
        self.dismiss(animated: false)
    }
    
    private func reconnectCloudxr() {
        let (success,reason) = arScreenController.reconnect()
        
    }
}

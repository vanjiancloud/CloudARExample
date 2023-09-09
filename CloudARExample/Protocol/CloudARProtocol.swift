//
//  CloudARProtocol.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import CloudAR

//MARK: 模型加载结束代理
protocol ModelLoadFinishProtocol
{
    /*
     isSuccess: 加载成功或失败
     reason: 加载失败的原因
     screenType: 加载的模式 ar, threeD
     project: 所加载的项目id
     */
    func handleModelLoadFinish(isSuccess: Bool, reason: String, screenType: car_ScreenMode, project: String)
}

protocol ThreeDURLProtocol
{
    func handleLoadThreeDURL()
}

//MARK: websocket
protocol SocketEventProtocol
{
    func handleReceiverMsg(json: inout [String:Any])
}

//MARK: 进入定位
protocol EnterPositionPtocotol
{
    func handleEnterPosition()
}

//MARK: 切换场景模式
protocol SwitchScreenModeProtocol
{
    func handleSwitchScreenMode(toScreenMode: car_ScreenMode)
}

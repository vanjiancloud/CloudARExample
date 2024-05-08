//
//  CloudARExtension.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import CloudAR
import UIKit

extension car_UserInfo
{
    static var name: String = ""
    static var imgUrl: String = ""
    static var threeDURL: String = "" //threeD画面流的url
}

extension car_URL
{
    static var javaWS: String = "wss://api.ourbim.com:11023"
}


extension car_EngineStatus
{
    static var lastExitARTime: Int = -1 //上次退出ar场景的时间
}

extension Date
{
    //秒级
    var timeStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return Int(timeInterval)
    }
}

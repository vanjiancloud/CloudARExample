//
//  WebSocketClient.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import Starscream
import CloudAR

class WebSocketClient : WebSocketDelegate
{
    
    public static let shared = WebSocketClient()
    
    private var socket: WebSocket?
    private var isConnected = false
    
    var socketProtocol: SocketEventProtocol?
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            isConnected = true
            print("ws connect success, headers:\(headers)")
        case let .disconnected(reason, code):
            isConnected = false
            print("disconnect, reason:\(reason),code:\(code)")
        case let .text(string):
            print("ws receive string")
            handleReceiverMessage(string: string)
        case let .binary(data):
            print("ws receive binary")
            handleReceiverMessage(data: data)
        case .pong:
            print("pong")
        case .ping:
            print("ping")
        case .viabilityChanged:
            print("viabilityChanged")
            break
        case .reconnectSuggested:
            print("reconnectSuggested")
            break
        case .cancelled:
            isConnected = false
            print("ws connect cancel")
        case let .error(error):
            isConnected = false
            print("ws connect error:\(String(describing: error))")
        case .peerClosed:
            isConnected = false
            print("peer closed")
        }
    }
    
    private func validOfURL() -> (Bool,String) {
        //return (true,"ws://120.86.64.201:16580/websocket")
        return (!car_UserInfo.taskID.isEmpty,"\(car_URL.javaWS)/vjapi/websocket/\(car_UserInfo.taskID)")
    }
    
    func connect() {
        let (valid,url) = validOfURL()
        if !valid {
            print("\(#function),\(url) is invalid")
            return
        }
        if socket == nil {
            var request = URLRequest(url: URL(string: url)!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        } else if !isConnected {
            socket?.connect()
        }
    }
    
    //MARK: 异步消息发送
    func sendMessage(_ message: String,completion: @escaping (Bool) -> Void) {
        if !isConnected {
            let (valid,url) = validOfURL()
            if !valid {
                return
            }
            
            if socket == nil {
                var request = URLRequest(url: URL(string: url)!)
                request.timeoutInterval = 5
                socket = WebSocket(request: request)
                socket?.delegate = self
            }
            
            socket?.onEvent = { event in
                switch event {
                case .connected:
                    self.socket?.write(string: message)
                    completion(true)
                default:
                    completion(false)
                }
            }
        } else
        {
            socket?.write(string: message)
            completion(true)
        }
    }
    
    //MARK: 处理接收到的消息
    private func handleReceiverMessage(data: Data) {
        guard var json = car_dataToJson(from: data)
        else {
            print("\(#function),data convert to json failed")
            return
        }
        dispatchReceiverMsg(json: &json)
        
    }
    
    private func handleReceiverMessage(string: String) {
        if let data = string.data(using: .utf8) {
            if var json = car_dataToJson(from: data) {
                dispatchReceiverMsg(json: &json)
            } else {
                print("\(#function),convert data to json failed: \(string)")
            }
        } else {
            print("\(#function),convert string to data failed")
        }
    }
   
    private func dispatchReceiverMsg(json: inout [String:Any]) {
       
        if let _ = json["id"] as? String {
            socketProtocol?.handleReceiverMsg(json: &json)
        } else {
            print("\(#function),not found is in json")
        }
    }
    
    func close() {
        socket?.forceDisconnect()
        socket = nil
    }
}



//
//  QueryFunc.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import CloudAR
import Alamofire

//MARK: 登录请求
func requestLogin(name: String,password: String,completion: @escaping(Bool,String) -> Void) {
    let url = car_URL.urlPre + "UserCenter/login?loginName=\(name)&password=\(password)"
    AF.request(url,method: .post).response { (response:AFDataResponse) in
        switch response.result {
            case .success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON ?? Data(), options: .allowFragments)
                    if let JSON = JSONObject as? [String:Any] {
                        if let respCode = JSON["code"] as? Int,
                           let msg = JSON["message"] as? String
                        {
                            if respCode == 0
                            {
                                if let data = JSON["data"] as? [String:Any] {
                                    //全局变量的数据设置 id ...
                                    car_UserInfo.userID = data["userid"] as? String ?? ""
                                    completion(true,"登录成功")
                                } else {
                                    completion(false,"响应数据错误")
                                }
                            } else {
                                completion(false,msg)
                            }
                        }
                    } else {
                        completion(false,"登陆响应失败")
                    }
                }
                break
            case .failure(_):
               completion(false,"登陆响应失败")
        }
    }
}

//MARK: 请求项目列表
func requestProjectList(completion: @escaping(Bool,[String:Any]?) -> Void) {
    let url = car_URL.urlPre + "appli/getApplicationList?userid=\(car_UserInfo.userID)&pageNo=1&pageSize=200"
    AF.request(url,method: .get).response { (response:AFDataResponse) in
        switch response.result {
            case .success(let JSON):
                do {
                    if let JSONObject = try? JSONSerialization.jsonObject(with: JSON ?? Data()),
                       let json = JSONObject as? [String:Any],
                       let respCode = json["code"] as? Int,
                       let data = json["data"] as? [String:Any],
                       respCode == 0
                    {
                        completion(true,data)
                    } else {
                        completion(false,nil)
                    }
                }
            case .failure(_):
                completion(false,nil)
        }
    }
}

//MARK: 获取token，用于请求模型
public func requestTokenForLoadModel(request: inout DataRequest?,auth: String,password: String,projectID: String,completion: @escaping (Result<String,Error>) -> Void)
{
    let url = car_URL.urlPre + "OurBim/getAccessToken?appid=\(projectID)&auth=\(auth)&password=\(password)"
    
    request = AF.request(url,method:.post).response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String
            {
                if code == 0 {
                    if let token = json["data"] as? String {
                        completion(.success(token))
                    } else {
                        completion(.failure(car_FError.customError(message: "not found data")))
                    }
                } else {
                    completion(.failure(car_FError.customError(message: msg)))
                }
            } else {
                completion(.failure(car_FError.customError(message: "not found code or message")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

fileprivate func requestARModel(request: inout DataRequest?,token: String,projectID: String,completion: @escaping (Result<String,Error>) ->Void) {
    if car_UserInfo.hostID.isEmpty {
        completion(.failure(car_FError.customError(message: "userinfo's hostID is empty")))
        return
    }
    let url = car_URL.urlPre + "OurBim/requestOurBim?appliId=\(projectID)&token=\(token)&appType=ar&senderId=\(car_UserInfo.senderID)&nonce=\(arc4random())&hostId=\(car_UserInfo.hostID)&mode=reboot"
    request = AF.request(url,method:.post)
    request?.response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String
            {
                if code == 0 {
                    if let data = json["data"] as? String {
                        completion(.success(data))
                    }
                } else {
                    completion(.failure(car_FError.customError(message: msg)))
                }
            } else {
                completion(.failure(car_FError.customError(message: "not found code or message")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

//MARK: 请求加载AR模型
func requestARModelLoad(request: inout DataRequest?,token:String,projectID: String,completion: @escaping (Bool,String) -> Void) {
    //请求模型
    requestARModel(request: &request,token: token, projectID: projectID) { result in
        switch result {
        case .success(let string):
            car_UserInfo.taskID = string
            car_UserInfo.currProID = projectID
            completion(true,"")
        case .failure(let error):
            print(error)
            if let carError = error as? car_FError {
                switch carError {
                case .customError(let message):
                    completion(false,message)
                    break
                }
            } else {
                completion(false,String(describing: error))
            }
            
        }
    }
}

//MARK: 请求加载threeD模型
func queryThreeDModelLoad(request: inout DataRequest?,token:String,projectID: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "OurBim/requestOurBim?appliId=\(projectID)&token=\(token)"
    request = AF.request(url,method:.post)
    request?.response { (response: AFDataResponse) in
        switch response.result {
        case .success(let JSON):
            do {
                if let jsonObject = try? JSONSerialization.jsonObject(with: JSON ?? Data(), options: .allowFragments),
                   let json = jsonObject as? [String:Any],
                   let code = json["code"] as? Int,
                   let message = json["message"] as? String,
                   let data = json["data"] as? [String:Any]
                {
                    if code == 0 {
                        if let taskID = data["taskId"] as? String,
                           let url = data["url"] as? String
                        {
                            car_UserInfo.taskID = taskID
                            car_UserInfo.currProID = projectID
                            car_UserInfo.threeDURL = url
                            completion(true,"success")
                        } else {
                            completion(false,"not found url or taskid")
                        }
                    } else {
                        completion(false,message)
                    }
                } else {
                    completion(false,"response data error")
                }
            }
        case .failure(_):
            completion(false,"response fail")
            break
        }
    }
}

//MARK: 模型退出
func sendModelQuit(screenType: car_ScreenMode) {
    switch screenType {
    case .AR:
        let url = car_URL.xrUrlPre + "v1/ShutDownTask?SenderId=\(car_UserInfo.senderID)&HostId=\(car_UserInfo.hostID)&nonce=\(arc4random())&taskid=\(car_UserInfo.taskID)"
        AF.request(url,method:.get).response { (_: AFDataResponse) in
        }
    case .ThreeD:
        //TODO:
        break
    case .None:
        break
    }
   
}

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

//MARK: 获取token
public func requestToken(request: inout DataRequest?,auth: String,password: String,projectID: String,completion: @escaping (Result<String,Error>) -> Void)
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

//MARK: 获取ip资源
func requestIp(request: inout DataRequest?,auth: String,password: String,projectID:String,completion: @escaping (Result<Void,Error>) -> Void) {
    requestToken(request: &request, auth: auth, password: password, projectID: projectID, completion: { result in
        switch result {
        case .success(let token):
            print("get token success")
            let url = car_URL.urlPre + "OurBim/requestXr?appliId=\(projectID)&plateType=3&token=\(token)"
            AF.request(url,method:.post).response { (response:AFDataResponse) in
                switch response.result {
                case .success(let data):
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
                       let json = jsonObject as? [String:Any],
                       let code = json["code"] as? Int,
                       let msg = json["message"] as? String
                    {
                        if code == 0 {
                            if let data = json["data"] as? [String:Any] {
                                //在这里预先把相关信息存储了，但后续的请求错误的话，这些数据应该手动失效
                                car_UserInfo.cloudarIP = data["publicIp"] as? String ?? ""
                                car_UserInfo.hostID = data["hostID"] as? String ?? ""
                                car_UserInfo.taskID = data["taskId"] as? String ?? ""
                                print("ip:\(car_UserInfo.cloudarIP),hostid:\(car_UserInfo.hostID),taskid:\(car_UserInfo.taskID)")
                                completion(.success(()))
                            }
                        } else {
                            completion(.failure(car_FError.customError(message: msg)))
                        }
                    }
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
                }
        case .failure(let error):
            print("get token fail")
            completion(.failure(error))
        }
    })
}

//MARK: 请求加载AR模型
func requestARModelLoad(request: inout DataRequest?,token: String,projectID: String,completion: @escaping (Bool,String) -> Void) {
    //请求模型
    if car_UserInfo.hostID.isEmpty || car_UserInfo.taskID.isEmpty {
        completion(false,"hostid or taskid is empty")
    }
    
    let url = car_URL.urlPre + "OurBim/startXr?appliId=\(projectID)&token=\(token)&plateType=3&senderId=\(car_UserInfo.senderID)&nonce=\(arc4random())&hostId=\(car_UserInfo.hostID)&mode=reboot&taskId=\(car_UserInfo.taskID)&accessMode=1"
    
    request = AF.request(url,method:.post)
    request?.response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String
            {
                completion(code == 0,msg)
                
            } else {
                completion(false,"response incomplete")
            }
        case .failure(_):
            completion(false,"request invalid")
        }
    }
}

//MARK: 请求加载threeD模型
func queryThreeDModelLoad(request: inout DataRequest?,token: String,projectID: String,completion: @escaping (Bool,String) -> Void) {
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
        let url = car_URL.urlPre + "OurBim/closeOurbim?taskId=\(car_UserInfo.taskID)"
        AF.request(url,method:.get).response { (_: AFDataResponse) in
        }
        // 关闭ar模型时，需要重启steamvr
        restartSteamvr(completion: {_,_ in })
    default:
        print("does not request")
    }
   
}

//MARK: 重启steamvr
func restartSteamvr(completion: @escaping (Bool,String) -> Void ) {
    let url = car_URL.xrUrlPre + "v1/StartupInsByProjectId?tag=ar&ProjectId=&mode=reboot&HostId=\(car_UserInfo.hostID)&SenderId=\(car_UserInfo.senderID)&nonce=\(arc4random())"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
            switch response.result {
            case .success(let JSON):
                do {
                    if let jsonObject = try? JSONSerialization.jsonObject(with: JSON ?? Data(), options: .allowFragments),
                       let json = jsonObject as? [String:Any],
                       let message = json["msg"] as? String,
                       let success = json["success"] as? Bool
                    {
                        completion(success,message)
                    } else {
                        completion(false,"response data error")
                    }
                }
            case .failure(_ ):
                completion(false,"request invalid")
            }
        }
}

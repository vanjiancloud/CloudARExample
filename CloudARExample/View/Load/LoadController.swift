//
//  LoadController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import Alamofire
import CloudAR

class LoadController: UIViewController,SocketEventProtocol
{
    var modelLoadView: LoadView!
    
    private var loadProgress: CGFloat = 0.0
    private var tokenRequest: DataRequest?
    private var modelLoadRequest: DataRequest?
    
    private var needLoadProject: String = "" //待加载的项目id
    private var needLoadMode: car_ScreenMode = .None //待加载的模式
    var modelLoadFinishProtocol: ModelLoadFinishProtocol? //项目启动后的代理
    var loadThreeDURLProcotol: ThreeDURLProtocol? //threeD视频流加载代理
    var loadInfo: (String,car_ScreenMode) {
        get {
            return (needLoadProject,needLoadMode)
        }
        set {
            needLoadProject = newValue.0
            needLoadMode = newValue.1
        }
    }
   
    override func viewDidLoad() {
        //self.view.frame
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        modelLoadView = LoadView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.view = modelLoadView
        
        tokenRequest = nil
        modelLoadRequest = nil
    }
    
    func handleReceiverMsg(json: inout [String : Any]) {
        if let id = json["id"] as? String {
            if id == "8" {
                if let progress = json["progress"] as? String {
                    print("场景加载进度：\(progress)")
                    self.loadProgress = CGFloat((progress as NSString).floatValue)
                }
            }
        }
    }
    
    func showLoadAnim(_ load: Bool)
    {
        if let loadView = self.view as? LoadView
        {
            if load == true
            {
                loadView.show()
            }
            else
            {
                loadView.hide()
            }
        }
    }
    
    //查询加载进度
    private func queryLoadProgress()
    {
        let timer: Timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            if self.loadProgress >= 1 {
                print("load progress > 1")
                timer.invalidate()
                self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: true, reason: "", screenType: self.needLoadMode, project: self.needLoadProject)
                self.needLoadProject = ""
                self.needLoadMode = .None
            }
        }
        timer.fire()
    }
    
    //请求模型加载
    func queryLoadModel()
    {
        print("query load model")
        
        loadProgress = 0.0 //重置加载进度
        
        //MARK: ourbim 请求模型加载接口
        let auth = UserDefaults.standard.string(forKey: "username") ?? ""
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
        print("auth:\(auth),password:\(password),projectID:\(needLoadProject)")
        requestTokenForLoadModel(request:&tokenRequest,auth: auth, password: password, projectID: needLoadProject) { result in
            switch result {
            case .success(let token):
                if self.needLoadMode == .AR {
                    requestARModelLoad(request:&self.modelLoadRequest,token: token, projectID: self.needLoadProject) { (result,msg) in
                        if result {
                            self.queryLoadProgress()
                            WebSocketClient.shared.connect()
                        } else {
                            self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: msg, screenType: .AR, project: self.needLoadProject)
                        }
                    }
                } else if self.needLoadMode == .ThreeD {
                    queryThreeDModelLoad(request: &self.modelLoadRequest, token: token, projectID: self.needLoadProject) { (result,msg) in
                        if result {
                            print("threeD model request success: url:\(car_UserInfo.threeDURL)")
                            self.loadThreeDURLProcotol?.handleLoadThreeDURL() //加载threeD url
                            self.queryLoadProgress()
                            WebSocketClient.shared.connect()
                        } else {
                            print("threeD model request fail: \(msg)")
                            self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: msg, screenType: .ThreeD, project: self.needLoadProject)
                        }
                    }
                }
            case .failure(let error):
                print("\(#function),\(error),get token failed")
                self.modelLoadFinishProtocol?.handleModelLoadFinish(isSuccess: false, reason: "token获取失败", screenType: .AR, project: self.needLoadProject)
            }
        }
    }
}

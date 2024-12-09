//
//  ProjectController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import CloudAR
import Alamofire

struct ProjectData
{
    var id: String
    var name: String
    var createTime: String
    var status: String
}

class ProjectController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    var projectView: ProjectView!
    private var projectList: [ProjectData] = []
    
    // 是否正在加载项目中，防止多次进入项目点击
    var loadingModel: Bool = false
    private var tokenRequest: DataRequest?
    
    override func loadView() {
        super.loadView()
        projectView = ProjectView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.view = projectView
        self.view.backgroundColor = .white
        projectView.table.dataSource = self
        projectView.table.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryProjectList()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectItemCell", for: indexPath) as? ProjectItemCell {
            cell.selectionStyle = .gray
            cell.data = indexPath.row < projectList.count ? projectList[indexPath.row] : nil
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.projectList.count {
            if !loadingModel {
                //默认是进入ar场景
                loadingModel = true
                let auth = UserDefaults.standard.string(forKey: "username") ?? ""
                let password = UserDefaults.standard.string(forKey: "password") ?? ""
                let projectId = projectList[indexPath.row].id
                
                requestIp(request: &tokenRequest, auth: auth, password: password, projectID: projectId, completion: { result in
                    switch result {
                    case .success(_):
                        restartSteamvr(completion: { success,reason in
                            // 在这里重启steamvr是为了在启动ar前能有个正常的环境，然后需要等待4-5s的重启过程
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                self.projectView?.table.cellForRow(at: indexPath)?.selectionStyle = .none
                                let controller = ScreenController()
                                controller.modalPresentationStyle = .fullScreen
                                self.present(controller, animated: false,completion: nil)
                                self.loadingModel = false
                                self.tokenRequest = nil
                                controller.loadModel(projectID: projectId, screenType: .AR)
                            }
                        })
                    case .failure(let error):
                        print("request ip fail: \(error)")
                        self.loadingModel = false
                        self.tokenRequest = nil
                        showTip(tip: "ip获取失败", parentView: self.view, false, completion: {
                            self.projectView?.table.cellForRow(at: indexPath)?.selectionStyle = .none
                        })
                    }
                })
            }
            else {
                    showTip(tip: "请勿重复进入", parentView: self.view, false, completion: {
                        self.projectView?.table.cellForRow(at: indexPath)?.selectionStyle = .none
                    })
                }
            }
        }
    
    private func queryProjectList() {
        requestProjectList(completion: {(isSuccess,result) in
            if isSuccess {
                if let data = result,
                   let list = data["list"] as? [[String:Any]]
                {
                    self.projectList.removeAll()
                    list.forEach{ (item) in
                        if let name = item["appName"] as? String,
                           let id = item["appid"] as? String,
                           let createTime = item["createTime"] as? String,
                           let status = item["applidStatus"] as? String
                        {
                            self.projectList.append(ProjectData(id: id, name: name, createTime: createTime, status: status))
                        }
                    }
                    self.projectView?.table.reloadData()
                }
            }
        })
    }
}


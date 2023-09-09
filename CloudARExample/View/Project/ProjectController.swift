//
//  ProjectController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import CloudAR

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
            //进入场景
            // 再此进入ar场景,需要间隔10s左右
            if car_EngineStatus.lastExitARTime < 0 || (Date().timeStamp - car_EngineStatus.lastExitARTime) > 10 {
                self.projectView?.table.cellForRow(at: indexPath)?.selectionStyle = .none
                let controller = ScreenController()
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: false,completion: nil)
                controller.loadModel(projectID: projectList[indexPath.row].id, screenType: .AR)
                
            } else {
                showTip(tip: "再等一会", parentView: self.view, false, completion: {
                    self.projectView?.table.cellForRow(at: indexPath)?.selectionStyle = .none
                })
            }
        } else {
            showTip(tip: "进入失败", parentView: self.view, false, completion: {
                self.projectView?.table.cellForRow(at: indexPath)?.selectionStyle = .none
            })
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

//
//  ProjectController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit

class ProjectController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var projectView: ProjectView!
    
    override func loadView() {
        super.loadView()
        projectView = ProjectView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.view = projectView
        projectView.table.dataSource = self
        projectView.table.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

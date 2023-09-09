//
//  ProjectView.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit

class ProjectItemCell: UITableViewCell
{
    var icon: UIImageView!
    var nameLabel: UILabel!
    var createTimeLabel: UILabel!
    var data: ProjectData? {
        didSet {
            if let new = data {
                nameLabel?.text = new.name
                createTimeLabel?.text = new.createTime
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //self.backgroundColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.7)
        
        icon = UIImageView()
        icon.image = UIImage(named: "projecticon")
        self.contentView.addSubview(icon)
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.7)
        self.contentView.addSubview(nameLabel)
        
        createTimeLabel = UILabel()
        createTimeLabel.font = .systemFont(ofSize: 12)
        createTimeLabel.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.7)
        self.contentView.addSubview(createTimeLabel)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 5),
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)
        ])
        createTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createTimeLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            createTimeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProjectView: UIView
{
    var title: UILabel!
    var table: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        title = UILabel()
        title.text = "项目列表"
        title.textColor = .black
        title.textAlignment = .center
        title.contentMode = .center
        title.font = .systemFont(ofSize: 24)
        addSubview(title)
        
        table = UITableView()
        table.register(ProjectItemCell.self, forCellReuseIdentifier: "ProjectItemCell")
        table.separatorStyle = .singleLine
        table.center.x = self.bounds.width / 2
        addSubview(table)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 20)
        ])
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            table.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            table.leftAnchor.constraint(equalTo: self.leftAnchor, constant: self.bounds.width * 0.25),
            table.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -self.bounds.width * 0.25)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

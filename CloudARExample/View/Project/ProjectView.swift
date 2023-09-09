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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        icon = UIImageView()
        icon.image = UIImage(named: "projecticon")
        self.contentView.addSubview(icon)
        
        nameLabel = UILabel()
        self.contentView.addSubview(nameLabel)
        
        createTimeLabel = UILabel()
        self.contentView.addSubview(createTimeLabel)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 5),
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10)
        ])
        createTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createTimeLabel.leftAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            createTimeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProjectView: UIView
{
    var table: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        table = UITableView(frame: CGRect(x: 0, y: 0, width: self.bounds.width * 0.8, height: self.bounds.height))
        addSubview(table)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

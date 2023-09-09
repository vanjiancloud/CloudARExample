//
//  LoginView.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit


class LoginView: UIView
{
    var name: UITextField!
    var password: UITextField!
    var confirm: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width: CGFloat = self.bounds.width
        
        name = UITextField(frame: CGRect(x: 0, y: 0, width: width * 0.8, height: 40))
        name.placeholder = "用户名"
        name.textAlignment = .justified
        name.layer.borderWidth = 0.5
        name.layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1).cgColor
        name.layer.cornerRadius = name.bounds.height / 2
        name.center.x = width / 2
        addSubview(name)
        
        password = UITextField(frame: CGRect(x: 0, y: 65, width: width * 0.8, height: 40))
        password.placeholder = "密码"
        password.textAlignment = .justified
        password.layer.borderWidth = 0.5
        password.layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1).cgColor
        password.layer.cornerRadius = password.bounds.height / 2
        password.center.x = width / 2
        addSubview(password)
        
        confirm = UIButton(frame: CGRect(x: 0, y: 140, width: width * 0.8, height: 40))
        confirm.backgroundColor = UIColor(red: 0.49, green: 0.894, blue: 1, alpha: 1)
        confirm.setTitle("登 录", for: .normal)
        confirm.layer.cornerRadius = confirm.bounds.height / 2
        confirm.center.x = width / 2
        addSubview(confirm)
        
        
        if let username = UserDefaults.standard.string(forKey: "username") {
            name?.text = username
        }
        if let psd = UserDefaults.standard.string(forKey: "password") {
            password?.text = psd
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

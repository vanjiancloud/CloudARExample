//
//  LoginController.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import CloudAR

class LoginController: UIViewController
{
    var loginView: LoginView!
    override func loadView() {
        self.modalPresentationStyle = .fullScreen
        super.loadView()
        let width: CGFloat = self.view.bounds.width
        let height: CGFloat = self.view.bounds.height
        loginView = LoginView(frame: CGRect(x: 0, y: height * 0.4, width: width * 0.4, height: height * 0.4))
        loginView.center.x = width / 2
        loginView.confirm.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        self.view.addSubview(loginView)
    }
    
    @objc private func handleLogin(_ sender: Any) {
        self.loginView?.confirm?.isEnabled = false
        let username = loginView?.name?.text
        let password = loginView?.password?.text
        if username?.count ?? 0 > 0 && password?.count ?? 0 > 0 {
            //进行登录
            requestLogin(name: username!, password: password!, completion: {(isSuccess,msg) in
                if isSuccess {
                    showTip(tip: msg, parentView: self.view, true, completion: {
                        self.loginView?.confirm?.isEnabled = true
                        
                        UserDefaults.standard.set(username!,forKey: "username")
                        UserDefaults.standard.set(password!,forKey: "password")
                        
                        // 跳转项目列表
                        let controller = ProjectController()
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller,animated: true)
                    })
                } else {
                    self.loginView?.confirm?.isEnabled = true
                    showTip(tip: msg, parentView: self.view, false, completion: {})
                }
            })
        } else {
            showTip(tip: "请填写账号密码", parentView: self.view, false, completion: {})
            self.loginView?.confirm?.isEnabled = true
        }
    }
}

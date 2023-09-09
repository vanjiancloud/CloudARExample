//
//  ScreenSubView.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit

class ScreenSubView: UIView
{
    var exitScreenBtn: BackBtnView! //场景退出按钮
    var switchModeView: SwitchModeView! //模式切换按钮
    var enterPositionBtn: EnterPositionView! //进入定位按钮
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        exitScreenBtn = BackBtnView(x: 0, y: 20, width: 40, height: 40)
        addSubview(exitScreenBtn)
        switchModeView = SwitchModeView(x: 70, y: 20)
        switchModeView.center.y = 40
        addSubview(switchModeView)
        enterPositionBtn = EnterPositionView(x: 150, y: 20, width: 40, height: 40)
        enterPositionBtn.center.y = 40
        addSubview(enterPositionBtn)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleExit(_ sender: Any) {
        print("hadnle exit")
    }
}

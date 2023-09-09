//
//  ViewTool.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit
import CloudAR

class BackBtnView: UIView
{
    var btn: UIButton!
    var img: UIImageView!
    init(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.layer.mask = makeMask(8,self.bounds,[.topRight,.bottomRight])
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        addSubview(btn)
        
        img = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        img.image = UIImage(named: "back")
        img.contentMode = .scaleAspectFit
        img.center = CGPoint(x: width/2,y: height/2)
        addSubview(img)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SwitchModeView: UIView
{
    var threeDLabel: UILabel!   //3d
    var arLabel: UILabel!       //ar
    var btnSwitch: UIButton!    //switch
    
    //width height 固定
    let width: CGFloat = 50
    let height: CGFloat = 90
    
    var switchModelProcotol: SwitchScreenModeProtocol?
    
    init(x: CGFloat,y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor(white: 1, alpha: 0)
        
        threeDLabel = UILabel()
        threeDLabel.text = "3D"
        threeDLabel.font = .systemFont(ofSize: 15)
        addSubview(threeDLabel)
        
        btnSwitch = UIButton()
        changeSwitchBG(toScreenMode: car_EngineStatus.screenMode)
        btnSwitch.contentMode = .scaleToFill
        addSubview(btnSwitch)
        
        arLabel = UILabel()
        arLabel.text = "AR"
        arLabel.font = .systemFont(ofSize: 15)
        addSubview(arLabel)
        
        btnSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btnSwitch.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            btnSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        threeDLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            threeDLabel.rightAnchor.constraint(equalTo: btnSwitch.leftAnchor, constant: -5),
            threeDLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        arLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arLabel.leftAnchor.constraint(equalTo: btnSwitch.rightAnchor, constant: 5),
            arLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func changeSwitchBG(toScreenMode: car_ScreenMode)
    {
        let switchImgName = toScreenMode == .AR ? "switchon" : "switchoff"
        let switchImg = UIImage(named: switchImgName)
        btnSwitch?.setImage(switchImg, for: .normal)
    }
}

class EnterPositionView: UIView
{
    var btn: UIButton!

    init(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.layer.mask = makeMask(8,self.bounds,[.bottomLeft,.bottomRight,.topLeft,.topRight])
        
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: width * 0.8, height: height * 0.8))
        btn.setBackgroundImage(UIImage(named: "enterposition"), for: .normal)
        btn.contentMode = .scaleAspectFill
        btn.center = CGPoint(x: width / 2, y: height / 2)
        addSubview(btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

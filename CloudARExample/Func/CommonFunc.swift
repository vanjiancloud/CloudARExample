//
//  CommonFunc.swift
//  CloudARExample
//
//  Created by lee on 2023/9/7.
//

import Foundation
import UIKit

//MARK: 展示一个tip
public func showTip(tip: String,parentView: UIView,center: CGPoint = CGPoint(x: 0, y: 0),_ isSuccess: Bool,completion: @escaping () -> Void)
{
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: min(parentView.bounds.width*0.35,400), height: 20))
    label.center = CGPoint(x: parentView.bounds.width / 2,y: parentView.bounds.height * 0.2)
    label.contentMode = .center
    label.textAlignment = .center
    label.text = tip
    label.textColor = UIColor.white
    label.backgroundColor = isSuccess ? UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1) : UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
    label.font = .systemFont(ofSize: 16)
    parentView.addSubview(label)
    
    UIView.animate(withDuration: 1.0, animations: {
        label.alpha = 0.5
    }) { (_) in
        UIView.animate(withDuration: 0.5) {
            label.alpha = 1
        } completion: { (_) in
            label.removeFromSuperview()
            completion()
        }
    }
    
}

//MARK: 制作一个mask
func makeMask(_ cornerRadius: CGFloat,_ viewBounds: CGRect,_ roundingCorn: UIRectCorner) -> CAShapeLayer
{
    // 创建圆角路径
    let maskPath = UIBezierPath(
        roundedRect: viewBounds,
        byRoundingCorners: roundingCorn,
        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
    )
    // 创建一个 shape layer
    let maskLayer = CAShapeLayer()
    maskLayer.path = maskPath.cgPath
    
    return maskLayer
}

//
//  View+Extensions.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation
import UIKit

extension UIView {
    func createHoleInMiddle(completion:@escaping((CGRect)->())) {
        let pathBigRect = UIBezierPath(rect: self.bounds)
        let smallRect = CGRect(x: (self.bounds.width / 2) - (300 / 2), y: (self.bounds.height / 2) - (200 / 2), width: 300, height: 200)
        let pathSmallRect = UIBezierPath(rect: smallRect)
        
        pathBigRect.append(pathSmallRect)
        pathBigRect.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = pathBigRect.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.8
        layer.addSublayer(fillLayer)
        
        completion(smallRect)
    }
}

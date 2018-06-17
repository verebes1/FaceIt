//
//  FaceView.swift
//  FaceIt
//
//  Created by verebes on 04/06/2017.
//  Copyright © 2017 verebes. All rights reserved.
//

import UIKit
import Foundation

//Public API

@IBDesignable class FaceView: UIView {
    /*If you are making something @IBInspectable you have to explicitely type what sort of var it is like Bool, Double etc because Interface Builder cannot infer what sort of variable it is. */
    @IBInspectable var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() }} //when it changes it will redraw view
    
    @IBInspectable var eyesOpen: Bool = true { didSet { setNeedsDisplay() }}
    
    @IBInspectable var mouthCurvature: Double = 1.0 { didSet { setNeedsDisplay() }} //1.0 fully smiling -1.0 full frown
    
    @IBInspectable var lineColor: UIColor = UIColor.blue { didSet { setNeedsDisplay() }}
    
    @IBInspectable var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() }}
    //I need to use @objc as #selector has been gone from Swift 4 
   @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale //+ pinchRecognizer.velocity
            //print(pinchRecognizer.velocity)
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    //Private implementation
    
    private struct Ratios {
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }
    
    private var skullRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    //Enum representing which eye are we dealing with
    private enum Eye {
        case left
        case right
    }
    //Function providing the path for the left or right eye
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        func centerOfEye(_eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeCenter = centerOfEye(_eye: eye)
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        
        //Below path comes uninitialized and it is a let however below it is only initialized once
        let path: UIBezierPath
        if eyesOpen{
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        } else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
        
        let mouthRect = CGRect(
            x: skullCenter.x - mouthWidth / 2,
            y: skullCenter.y + mouthOffset,
            width: mouthWidth,
            height: mouthHeight
        )
        
        //Below the mouthCurvature is forced to be between -1 and 1
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        //Controlpoint cp1 start points X and you add 1/3 of the mouthrect width same with end just subtract 1/3
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: start.y + smileOffset)

        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
        
    }
    
    //Function providing the path or the skull
    private func pathForSkull() -> UIBezierPath
    {
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        path.lineWidth = lineWidth
        return path
    }
    
    //Main Drawing function below
    override func draw(_ rect: CGRect) {
        lineColor.set()
        pathForSkull().stroke()
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
}

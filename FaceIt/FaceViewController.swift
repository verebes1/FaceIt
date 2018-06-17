//
//  FaceViewController.swift
//  FaceIt
//
//  Created by verebes on 04/06/2017.
//  Copyright © 2017 verebes. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {
    var currentColour = 0
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            let handler = #selector(FaceView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: faceView, action: handler)
            faceView.addGestureRecognizer(pinchRecognizer)
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleEyes(byReactingTo:)))
            tapRecognizer.numberOfTapsRequired = 2 //we configure it that you need to do a double tap to make it happen
            faceView.addGestureRecognizer(tapRecognizer)
            let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(increaseHappiness))
            swipeUpRecognizer.direction = .up
            faceView.addGestureRecognizer(swipeUpRecognizer)
            let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(decreaseHappiness))
            swipeDownRecognizer.direction = .down
            faceView.addGestureRecognizer(swipeDownRecognizer)
            let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(colorChange))
            swipeLeftRecognizer.direction = .left
            faceView.addGestureRecognizer(swipeLeftRecognizer)
            updateUI()
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    //we dont need any arguments like byReactingTo because swipe gesture is discrete and dont need arguments
  @objc  func increaseHappiness() {
        expression = expression.happier
    }
    
  @objc  func decreaseHappiness() {
        expression = expression.sadder
    }
    
   @objc func colorChange() {
    let lineColours: [UIColor] = [UIColor.red,UIColor.black,UIColor.green,UIColor.brown,UIColor.white]
    //print("trying to change colour")
    if currentColour < lineColours.count {
        faceView.lineColor = lineColours[currentColour]
        currentColour += 1
    } else {
        currentColour = 0
        faceView.lineColor = lineColours[currentColour]
    }
    }
    
@objc func toggleEyes(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended { //if my eyes are closed they will open if opposite they will be closed
            let eyes: FacialExpression.Eyes = (expression.eyes == .closed) ? .open : .closed
            expression = FacialExpression(eyes: eyes, mouth: expression.mouth)
        }
    }
    
    var expression = FacialExpression(eyes: .open, mouth: .smile) {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI(){
        switch expression.eyes {
        case .open:
            faceView?.eyesOpen = true   //we use the ? so that if it is nill it will ignore the rest of the code
        case .closed:
            faceView?.eyesOpen = false
        case .squinting:
            faceView?.eyesOpen = false
        }
        //below if mouthCurvatures[expression.mouth] does not exist as it is an optional it might not exist we are defaulting it to 0.0
        faceView?.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
    }
    
    //Swift inferes from the first element that it is FacialExpression.Mouth.XXXX this is why the next item can be written with the omited FacialExpression.Mouth as for example .frown
    private let mouthCurvatures = [FacialExpression.Mouth.grin:0.5, .frown:-1.0, .smile:1.0, .neutral:0.0, .smirk:-0.5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    
    
}


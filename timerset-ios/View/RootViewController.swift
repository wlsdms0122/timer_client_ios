//
//  RootViewController.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class RootViewController: UINavigationController {
    // MARK: properties
    var coordinator: RootViewCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide top navigtaion bar
        isNavigationBarHidden = true
        // set default swipe back gesture because if isNavigationBarHidden property is true, interactive gesture isn't work
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension RootViewController: UIGestureRecognizerDelegate {
    // when a gesture recognizer attempts to transition out of the UIGestureRecognizer.State.possible state
    // Returning false causes the gesture recognizer to transition to the UIGestureRecognizer.State.failed state.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // prevent interactivePopGesture if view controller is top controller
        return viewControllers.count > 1 ? true : false
    }
    
    // when return false (default is true), gesture recognizer doesn't notified touch event accured
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
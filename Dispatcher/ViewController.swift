//
//  ViewController.swift
//  Dispatcher
//
//  Created by Luciano Marisi on 04/02/2016.
//  Copyright © 2016 Techbrewers LTD. All rights reserved.
//

import UIKit
import CoreMotion

struct Point : Dispatchable, Motionable {
  let timestamp : NSTimeInterval
  let gravity : CMAcceleration
}

class ViewController: UIViewController {
  
  let dispatcher = Dispatcher()
  let deviceMotionWrapper = DeviceMotionWrapper()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

    var mockPoints = [Point]()
    
    for index in 0...100 {
      let value = Double(index)
      let gravity = CMAcceleration(x: value, y: value, z: value)
      let mockPoint = Point(timestamp: NSTimeInterval(index) / 10, gravity: gravity)
      mockPoints.append(mockPoint)
    }
    
    deviceMotionWrapper.startDeviceMotionUpdates(mockPoints) { (motionable, error) -> Void in
      NSLog("\(motionable.gravity)")
    }
    
//    deviceMotionWrapper.startDeviceMotionUpdates { (motionable, error) -> Void in
//      NSLog("\(motionable.gravity)")
//    }

  }
  
}


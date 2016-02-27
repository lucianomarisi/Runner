//
//  ViewController.swift
//  RunnerExampleApp
//
//  Created by Luciano Marisi on 27/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import UIKit
import Runner
import CoreMotion

class ViewController: UIViewController {
  
  let deviceMotionWrapper = DeviceMotionWrapper()
  
  override func viewDidLoad() {
    super.viewDidLoad()

//    deviceMotionWrapper.startDeviceMotionUpdates(sineSignal, timeInterval: 0.1) { (point, error) -> Void in
//      NSLog("\(point.userAcceleration)")
//    }
    
    var mockPoints = [MotionablePoint]()
    
    for index in 0...100 {
      let value = Double(index)
      let userAcceleration = CMAcceleration(x: value, y: value, z: value)
      let mockPoint = MotionablePoint(timestamp: NSTimeInterval(index) / 10, userAcceleration: userAcceleration)
      mockPoints.append(mockPoint)
    }

    deviceMotionWrapper.startDeviceMotionUpdates(mockPoints) { (point, error) -> Void in
      NSLog("\(point)")
    }
  }
  
}

// A.sin(f.t+phaseShift)+offset
func sineSignal(nextTimestamp: NSTimeInterval) -> MotionablePoint {
  let signalFrequency = 1.0
  let amplitude = 2.0
  let offset = 0.5
  let phaseShift = 0.2
  let value = amplitude * sin(nextTimestamp * signalFrequency + phaseShift) + offset
  let userAcceleration = CMAcceleration(x: value, y: value, z: value)
  return MotionablePoint(timestamp: nextTimestamp, userAcceleration: userAcceleration)
}
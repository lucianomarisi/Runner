//
//  ViewController.swift
//  Dispatcher
//
//  Created by Luciano Marisi on 04/02/2016.
//  Copyright © 2016 Techbrewers LTD. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
  
  let dispatcher = Dispatcher()
  let deviceMotionWrapper = DeviceMotionWrapper()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

//    dispatcher.startWithFunction(sineSignal) { (point) -> Void in
//      NSLog("\(point.value)")
//    }
    
    var mockPoints = [Point]()
    
    for index in 0...10 {
      let mockPoint = Point(timestamp: NSTimeInterval(index) / 10, value: Double(index))
      mockPoints.append(mockPoint)
    }
    
    dispatcher.startWithMockPoints(mockPoints) { (point) -> Void in
      NSLog("\(point.value)")
    }

  }

}

// A.sin(f.t)+offset
func sineSignal(nextTimestamp: NSTimeInterval) -> Point {
  let signalFrequency = 1.0
  let amplitude = 2.0
  let offset = 0.5
  let phaseShift = 0.2
  let value = amplitude * sin(nextTimestamp * signalFrequency + phaseShift) + offset
  return Point(timestamp: nextTimestamp, value: value)
}



extension ViewController {
  
  struct MotionablePoint : Dispatchable, Motionable {
    let timestamp : NSTimeInterval
    let gravity : CMAcceleration
  }
  
  func mockAccelerometer() {
    var mockPoints = [MotionablePoint]()
    
    for index in 0...100 {
      let value = Double(index)
      let gravity = CMAcceleration(x: value, y: value, z: value)
      let mockPoint = MotionablePoint(timestamp: NSTimeInterval(index) / 10, gravity: gravity)
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


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

protocol Motionable {
  var gravity : CMAcceleration { get }
}

extension CMDeviceMotion : Motionable {}

class ViewController: UIViewController {
  
  let dispatcher = Dispatcher()
  let deviceMotionWrapper = DeviceMotionWrapper()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    deviceMotionWrapper.startDeviceMotionUpdates { (sensorable, error) -> Void in
      NSLog("\(sensorable)")
    }
  }
  
}


class DeviceMotionWrapper {
  
  private var motionManager : CMMotionManager = {
    let motionManager = CMMotionManager()
    motionManager.deviceMotionUpdateInterval = 0.01
    return motionManager
  }()
  
  private var queue : NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  private let dispatcher = Dispatcher()
  
  func startDeviceMotionUpdates(handler: (Motionable, NSError?) -> Void) {
    
    if !motionManager.deviceMotionAvailable {
      
      var mockPoints = [Point]()
      
      for index in 0...100 {
        let value = Double(index)
        let gravity = CMAcceleration(x: value, y: value, z: value)
        let mockPoint = Point(timestamp: NSTimeInterval(index) / 10, gravity: gravity)
        mockPoints.append(mockPoint)
      }
      
      dispatcher.startWithClosure(mockPoints) { (mockPoint) -> Void in
        handler(mockPoint, nil)
      }
    } else {
      motionManager.startDeviceMotionUpdatesToQueue(queue) {(deviceMotion, error) -> Void in
        
        guard let deviceMotion = deviceMotion else {
          return
        }
        handler(deviceMotion, error)
      }
    }
  }
  
  func stopDeviceMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }
  
}
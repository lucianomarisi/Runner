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
    
//    deviceMotionWrapper.startDeviceMotionUpdates(deviceMotionWrapper.startMockedDeviceMotionUpdates) { (motionable, error) -> Void in
//      NSLog("\(motionable)")
//    }
    
    deviceMotionWrapper.startDeviceMotionUpdates { (motionable, error) -> Void in
      NSLog("\(motionable)")
    }

  }
  
}

typealias DeviceMotionHandler = (Motionable, NSError?) -> Void
typealias DeviceMotionHandlerFunction = DeviceMotionHandler -> Void

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
  
  func startDeviceMotionUpdates(deviceMotionFunction: DeviceMotionHandlerFunction? = nil, handler: DeviceMotionHandler) {
    
    if deviceMotionFunction != nil {
      deviceMotionFunction?(handler)
    } else {
      startRealDeviceMotionUpdates(handler)
    }
  }
  
  private func startMockedDeviceMotionUpdates(handler: DeviceMotionHandler) {
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
  }
  
  private func startRealDeviceMotionUpdates(handler: DeviceMotionHandler) {
    motionManager.startDeviceMotionUpdatesToQueue(queue) {(deviceMotion, error) -> Void in
      
      guard let deviceMotion = deviceMotion else {
        return
      }
      handler(deviceMotion, error)
    }
  }
  
  func stopDeviceMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }
  
}
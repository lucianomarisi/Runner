//
//  DeviceMotionWrapper.swift
//  Dispatcher
//
//  Created by Luciano Marisi on 07/02/2016.
//  Copyright © 2016 Techbrewers LTD. All rights reserved.
//

import CoreMotion

protocol Motionable {
  var rotationRate: CMRotationRate { get }
  var gravity: CMAcceleration { get }
  var userAcceleration: CMAcceleration { get }
}

extension Motionable {
  var rotationRate: CMRotationRate { return CMRotationRate() }
  var gravity: CMAcceleration { return CMAcceleration() }
  var userAcceleration: CMAcceleration { return CMAcceleration() }
}

extension CMDeviceMotion : Motionable {}

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
  
  func startDeviceMotionUpdates<T where T : Dispatchable, T : Motionable>(mockPoints: [T]? = nil, handler: DeviceMotionHandler) {
    
    if mockPoints != nil {
      startMockedDeviceMotionUpdates(mockPoints!, handler: handler)
    } else {
      startRealDeviceMotionUpdates(handler)
    }
    
  }
  
  private func startMockedDeviceMotionUpdates<T where T : Dispatchable, T : Motionable>(mockPoints: [T], handler: DeviceMotionHandler) {
    
    dispatcher.startWithMockPoints(mockPoints) { (mockPoint) -> Void in
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
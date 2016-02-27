//
//  DeviceMotionWrapper.swift
//  Runner
//
//  Created by Luciano Marisi on 27/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import CoreMotion
import Runner

extension CMDeviceMotion : Motionable {}

typealias DeviceMotionHandler = (Motionable, NSError?) -> Void

private let defaultDeviceMotionUpdateInterval = 0.01

class DeviceMotionWrapper {
  
  private var motionManager : CMMotionManager = {
    let motionManager = CMMotionManager()
    motionManager.deviceMotionUpdateInterval = defaultDeviceMotionUpdateInterval
    return motionManager
  }()
  
  private var queue : NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  
  func startDeviceMotionUpdates(handler: CMDeviceMotionHandler) {
    motionManager.startDeviceMotionUpdatesToQueue(queue) {(deviceMotion, error) -> Void in
      
      guard let deviceMotion = deviceMotion else {
        return
      }
      handler(deviceMotion, error)
    }
  }
  
  private let runner = Runner()
  
  func startDeviceMotionUpdates<PointType : protocol<Runnable, Motionable>>(mockPoints: [PointType]? = nil, timeInterval: Double = defaultDeviceMotionUpdateInterval, handler: DeviceMotionHandler) {
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      if let mockPoints = mockPoints {
        startMockedDeviceMotionUpdates(mockPoints, handler: handler)
        return
      }
    #endif
    
    motionManager.deviceMotionUpdateInterval = timeInterval
    startRealDeviceMotionUpdates(handler)
    
  }
  
  func startDeviceMotionUpdates<PointType : protocol<Runnable, Motionable>>(signalFunction: (NSTimeInterval -> PointType)? = nil, timeInterval: Double = defaultDeviceMotionUpdateInterval, handler: DeviceMotionHandler) {
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      if let signalFunction = signalFunction {
        startMockedDeviceMotionUpdates(signalFunction, timeInterval: timeInterval, handler: handler)
        return
      }
    #endif
    
    motionManager.deviceMotionUpdateInterval = timeInterval
    startRealDeviceMotionUpdates(handler)
    
  }
  
  private func startMockedDeviceMotionUpdates<PointType : protocol<Runnable, Motionable>>(mockPoints: [PointType], handler: DeviceMotionHandler) {
    
    runner.startWithMockPoints(mockPoints) { (mockPoint) -> Void in
      handler(mockPoint, nil)
    }
    
  }
  
  private func startMockedDeviceMotionUpdates<PointType : protocol<Runnable, Motionable>>(signalFunction: (NSTimeInterval -> PointType),  timeInterval: Double = defaultDeviceMotionUpdateInterval, handler: DeviceMotionHandler) {
    
    runner.startWithFunction(signalFunction, timeInterval: timeInterval) { (mockPoint) -> Void in
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
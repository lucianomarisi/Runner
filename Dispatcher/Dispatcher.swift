//
//  Dispatcher.swift
//  Dispatcher
//
//  Created by Luciano Marisi on 04/02/2016.
//  Copyright © 2016 Techbrewers LTD. All rights reserved.
//

import Foundation

typealias TimeSchedulerClosure = (Dispatchable) -> Void
typealias TimeSchedulerCompleteClosure = Void -> Void

protocol Dispatchable {
  var timestamp : NSTimeInterval { get }
}

class Dispatcher {
  
  private let dispatchQueue = dispatch_queue_create("Dispatcher_serial_queue", DISPATCH_QUEUE_SERIAL)
  
  private var startDate = NSDate()
  
  /// This closure will be called the TimeScheduler finishes firing data
  var scheduleCompleteClosure : TimeSchedulerCompleteClosure?
  
  /**
   Start firing the points in a array
   
   - parameter mockPoints:          The array of points to iterate
   - parameter pointProcessClosure: The closure to be executed when at point if fired, contains the point itself
   */
  func startWithClosure<T: Dispatchable>(mockPoints: [T], pointProcessClosure: (T) -> Void) {
    startDate = NSDate()
    firePointAtIndex(0, mockPoints: mockPoints, pointProcessClosure: pointProcessClosure)
  }
  
  private func firePointAtIndex<T : Dispatchable>(currentIndex: Int, mockPoints: [T], pointProcessClosure: (T) -> Void) {
    if currentIndex >= mockPoints.count {
      scheduleCompleteClosure?()
      return
    }
    let currentPoint = mockPoints[currentIndex]
    let timeSinceStart = -startDate.timeIntervalSinceNow
    let delayInSeconds = currentPoint.timestamp - timeSinceStart
    let dispatchTimeDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
    dispatch_after(dispatchTimeDelay, dispatchQueue) {
      pointProcessClosure(mockPoints[currentIndex])
      let nextIndex = currentIndex + 1
      self.firePointAtIndex(nextIndex, mockPoints: mockPoints, pointProcessClosure: pointProcessClosure)
    }
  }
}
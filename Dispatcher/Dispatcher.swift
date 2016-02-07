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

struct Point : Dispatchable {
  let timestamp : NSTimeInterval
  let value : Double
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
  func startWithMockPoints<T: Dispatchable>(mockPoints: [T], pointProcessClosure: (T) -> Void) {
    startDate = NSDate()
    firePointAtIndex(0, mockPoints: mockPoints, pointProcessClosure: pointProcessClosure)
  }
  
  func startWithFunction(pointProcessClosure: (Point) -> Void) {
    startDate = NSDate()
    let nextPoint = Point(timestamp: startDate.timeIntervalSinceNow, value: 0)
    self.firePoint(nextPoint, pointProcessClosure: pointProcessClosure)
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
  
  // MARK: Dispatching using function
  
  private func firePoint(pointToFire: Point, pointProcessClosure: (Point) -> Void) {
    let timeSinceStart = -startDate.timeIntervalSinceNow
    let delayInSeconds = pointToFire.timestamp - timeSinceStart
    let dispatchTimeDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
    dispatch_after(dispatchTimeDelay, dispatchQueue) {
      pointProcessClosure(pointToFire)
      let nextPoint = self.calculateNextPoint(pointToFire.timestamp)
      self.firePoint(nextPoint, pointProcessClosure: pointProcessClosure)
    }
  }
  
  private let samplingFrequency = 0.1
  private func calculateNextPoint(currentTimestamp: NSTimeInterval) -> Point {
    let signalFrequency = 1.0
    let amplitude = 2.0
    let offset = 0.5
    let value = amplitude * sin(currentTimestamp * signalFrequency) + offset
    return Point(timestamp: currentTimestamp + samplingFrequency, value: value)
  }
  
}
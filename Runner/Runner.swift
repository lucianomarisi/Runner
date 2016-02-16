//
//  Runner.swift
//  Runner
//
//  Created by Luciano Marisi on 16/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import Foundation

/**
 *  Protocol useful to execute any struct/class at a specific timestamp
 */
public protocol Runnable {
  var timestamp : NSTimeInterval { get }
}

/**
 *  Struct used to represent a point in time that has been executed by a function
 */
public struct Point : Runnable {
  
  /// The timestamp of the point
  public let timestamp : NSTimeInterval
  
  /// The numerical value of the point
  public let value : Double
}

private let defaultSamplingFrequency = 0.1

/// Object used to run points at specific times
public final class Runner {
  
  private let dispatchQueue = dispatch_queue_create("Runner_serial_queue", DISPATCH_QUEUE_SERIAL)
  private var startDate = NSDate()
  private var timeInterval : Double = defaultSamplingFrequency
  private var shouldExecutePoints = true
  
  /// This closure will be called the TimeScheduler finishes firing data
  public var scheduleCompleteClosure : (Void -> Void)?
  
  /**
   Start firing the points in a array
   
   - parameter mockPoints:          The array of points to iterate
   - parameter pointProcessClosure: The closure to be executed when at point if fired, contains the point itself
   */
  public func startWithMockPoints<T: Runnable>(mockPoints: [T], pointProcessClosure: (T) -> Void) {
    setupStartState()
    firePointAtIndex(0, mockPoints: mockPoints, pointProcessClosure: pointProcessClosure)
  }
  
  /**
   Start running points using a function
   
   - parameter timeInterval:        The time interval the points will be executed
   - parameter signalFunction:      The function to generate the points
   - parameter pointProcessClosure: The closure executed after each point
   */
  public func startWithFunction(signalFunction: (NSTimeInterval -> Point), timeInterval: Double = defaultSamplingFrequency, pointProcessClosure: (Point) -> Void) {
    setupStartState()
    self.timeInterval = timeInterval
    let timestamp = startDate.timeIntervalSinceNow
    let firstPoint = signalFunction(timestamp)
    self.firePoint(firstPoint, signalFunction: signalFunction, pointProcessClosure: pointProcessClosure)
  }
  
  /**
   Stops executing points
   */
  public func stop() {
    shouldExecutePoints = false
  }
  
  // MARK: Run using provided array of Runnable items
  
  private func firePointAtIndex<T : Runnable>(currentIndex: Int, mockPoints: [T], pointProcessClosure: (T) -> Void) {
    if currentIndex >= mockPoints.count || !shouldExecutePoints {
      runningStopped()
      return
    }
    let currentPoint = mockPoints[currentIndex]
    let dispatchTimeDelay = dispatchTimeDelayWithTimestamp(currentPoint.timestamp)
    dispatch_after(dispatchTimeDelay, dispatchQueue) {
      pointProcessClosure(mockPoints[currentIndex])
      let nextIndex = currentIndex + 1
      self.firePointAtIndex(nextIndex, mockPoints: mockPoints, pointProcessClosure: pointProcessClosure)
    }
  }
  
  // MARK: Run using function
  
  private func firePoint(pointToFire: Point, signalFunction: (NSTimeInterval -> Point), pointProcessClosure: (Point) -> Void) {
    if !shouldExecutePoints {
      runningStopped()
      return
    }
    let dispatchTimeDelay = dispatchTimeDelayWithTimestamp(pointToFire.timestamp)
    dispatch_after(dispatchTimeDelay, dispatchQueue) {
      pointProcessClosure(pointToFire)
      let nextPoint = signalFunction(pointToFire.timestamp + self.timeInterval)
      self.firePoint(nextPoint, signalFunction: signalFunction, pointProcessClosure: pointProcessClosure)
    }
  }
  
  // MARK: Helpers
  
  private func dispatchTimeDelayWithTimestamp(timestamp: NSTimeInterval) -> dispatch_time_t {
    let timeSinceStart = -startDate.timeIntervalSinceNow
    let delayInSeconds = timestamp - timeSinceStart
    return dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
  }
  
  private func setupStartState() {
    startDate = NSDate()
    shouldExecutePoints = true
  }
  
  private func runningStopped() {
    scheduleCompleteClosure?()
    shouldExecutePoints = true
  }
  
}
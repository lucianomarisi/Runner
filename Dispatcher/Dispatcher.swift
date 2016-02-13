//
//  Dispatcher.swift
//  Dispatcher
//
//  Created by Luciano Marisi on 04/02/2016.
//  Copyright © 2016 Techbrewers LTD. All rights reserved.
//

import Foundation

/**
 *  Protocol useful to dispatch any struct/class at a specific timestamp
 */
public protocol Dispatchable {
  var timestamp : NSTimeInterval { get }
}

/**
 *  Struct used to represent a point in time that has been dispatch by a function
 */
public struct Point : Dispatchable {

  /// The timestamp of the point
  public let timestamp : NSTimeInterval
  
  /// The numerical value of the point
  public let value : Double
}

private let defaultSamplingFrequency = 0.1

/// Object used to dispatch points at specific times
public final class Dispatcher {
  
  private let dispatchQueue = dispatch_queue_create("Dispatcher_serial_queue", DISPATCH_QUEUE_SERIAL)
  private var startDate = NSDate()
  private var timeInterval : Double = defaultSamplingFrequency
  private var shouldDispatchPoints = true
  
  /// This closure will be called the TimeScheduler finishes firing data
  public var scheduleCompleteClosure : (Void -> Void)?
  
  /**
   Start firing the points in a array
   
   - parameter mockPoints:          The array of points to iterate
   - parameter pointProcessClosure: The closure to be executed when at point if fired, contains the point itself
   */
  public func startWithMockPoints<T: Dispatchable>(mockPoints: [T], pointProcessClosure: (T) -> Void) {
    setupStartState()
    firePointAtIndex(0, mockPoints: mockPoints, pointProcessClosure: pointProcessClosure)
  }
  
  /**
   Start dispatching point using a function
   
   - parameter timeInterval:        The time interval the points will be dispatched
   - parameter signalFunction:      The function to generate the points
   - parameter pointProcessClosure: The closure executed after each point
   */
  public func startWithFunction(signalFunction: (NSTimeInterval -> Point), timeInterval: Double = defaultSamplingFrequency, pointProcessClosure: (Point) -> Void) {
    setupStartState()
    self.timeInterval = timeInterval
    let nextPoint = Point(timestamp: startDate.timeIntervalSinceNow, value: 0)
    self.firePoint(nextPoint, signalFunction: signalFunction, pointProcessClosure: pointProcessClosure)
  }
  
  /**
   Stops dispatching points
   */
  public func stop() {
    shouldDispatchPoints = false
  }
  
  // MARK: Dispatching using provided array of Dispatchable items
  
  private func firePointAtIndex<T : Dispatchable>(currentIndex: Int, mockPoints: [T], pointProcessClosure: (T) -> Void) {
    if currentIndex >= mockPoints.count || !shouldDispatchPoints {
      dispatchingStopped()
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
  
  // MARK: Dispatching using function
  
  private func firePoint(pointToFire: Point, signalFunction: (NSTimeInterval -> Point), pointProcessClosure: (Point) -> Void) {
    if !shouldDispatchPoints {
      dispatchingStopped()
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
    shouldDispatchPoints = true
  }
  
  private func dispatchingStopped() {
    scheduleCompleteClosure?()
    shouldDispatchPoints = true
  }
  
}
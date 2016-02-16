//
//  RunnerTests.swift
//  RunnerTests
//
//  Created by Luciano Marisi on 16/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  
  let acceptableTolerance = 0.2 // seconds, test suite appears to run slower than app
  
  func testMockPointsRunning() {
    let expectation = expectationWithDescription("testMockPointsRunning")
    let runner = Runner()
    var mockPoints = [Point]()
    
    let numberOfPoints = 10
    let totalTime = 1.0
    for index in 0...numberOfPoints {
      let timestamp = NSTimeInterval(index) * totalTime / Double(numberOfPoints)
      let mockPoint = Point(timestamp: timestamp, value: Double(index))
      mockPoints.append(mockPoint)
    }
    
    let startDate = NSDate()
    runner.startWithMockPoints(mockPoints) { (point) -> Void in
      let currentDate = NSDate()
      let difference = currentDate.timeIntervalSinceDate(startDate)
      let deviation = difference - point.timestamp
      XCTAssert(abs(deviation) < self.acceptableTolerance)
      NSLog("testMockPointsRunning \(point.value)")
    }
    
    runner.scheduleCompleteClosure = {
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(totalTime + 1) { error in XCTAssert(error == nil) }
    
  }
  
  func testFunctionRunning() {
    let expectation = expectationWithDescription("testFunctionRunning")
    let runner = Runner()
    let startDate = NSDate()
    let totalTime = 1.0
    runner.startWithFunction(sineSignal) { (point) -> Void in
      let expectedValue = self.sineSignal(point.timestamp).value
      XCTAssertEqual(expectedValue, point.value)
      let currentDate = NSDate()
      let difference = currentDate.timeIntervalSinceDate(startDate)
      let deviation = difference - point.timestamp
      XCTAssert(abs(deviation) < self.acceptableTolerance)
      NSLog("testFunctionRunning \(point.value)")
    }
    
    runner.scheduleCompleteClosure = {
      expectation.fulfill()
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(totalTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
      runner.stop()
    }
    waitForExpectationsWithTimeout(totalTime + 1) { error in XCTAssert(error == nil) }
    
  }
  
  // MARK: Helpers
  
  func sineSignal(nextTimestamp: NSTimeInterval) -> Point {
    let signalFrequency = 1.0
    let amplitude = 2.0
    let offset = 0.5
    let phaseShift = 0.2
    let value = amplitude * sin(nextTimestamp * signalFrequency + phaseShift) + offset
    return Point(timestamp: nextTimestamp, value: value)
  }
  
}


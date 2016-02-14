//
//  DispatcherTests.swift
//  DispatcherTests
//
//  Created by Luciano Marisi on 14/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import XCTest
@testable import Dispatcher

class DispatcherTests: XCTestCase {

  let acceptableTolerance = 0.2 // seconds, test suite appears to run slower than app
  
  func testMockPoints() {
    let expectation = expectationWithDescription("MockPoints")
    let dispatcher = Dispatcher()
    var mockPoints = [Point]()

    let numberOfPoints = 10
    let totalTime = 1.0
    for index in 0...numberOfPoints {
      let timestamp = NSTimeInterval(index) * totalTime / Double(numberOfPoints)
      let mockPoint = Point(timestamp: timestamp, value: Double(index))
      mockPoints.append(mockPoint)
    }
    
    let startDate = NSDate()
    dispatcher.startWithMockPoints(mockPoints) { (point) -> Void in
      let currentDate = NSDate()
      let difference = currentDate.timeIntervalSinceDate(startDate)
      let deviation = difference - point.timestamp
      XCTAssert(abs(deviation) < self.acceptableTolerance)
    }
    
    dispatcher.scheduleCompleteClosure = {
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(totalTime + 1) { error in XCTAssert(error == nil) }
  
  }
  
}

//
//  Point.swift
//  Runner
//
//  Created by Luciano Marisi on 27/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import Foundation

/**
 *  Struct used to represent a point in time that has been executed by a function
 */
public struct Point : Runnable {
  
  /// The timestamp of the point
  public let timestamp : NSTimeInterval
  
  /// The numerical value of the point
  public let value : Double
  
  /**
   Designated initializer for a point
   
   - parameter timestamp: The timestamp of the point
   - parameter value:     The numerical value of the point
   
   - returns: An initiliazed point
   */
  public init (timestamp: NSTimeInterval, value: Double) {
    self.timestamp = timestamp
    self.value = value
  }
  
}
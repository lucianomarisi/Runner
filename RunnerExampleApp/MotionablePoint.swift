//
//  MotionablePoint.swift
//  Runner
//
//  Created by Luciano Marisi on 27/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import CoreMotion
import Runner

/**
 *  Struct used to represent a point in time that has been executed by a function
 */
struct MotionablePoint : Runnable, Motionable {
  
  /// The timestamp of the point
  let timestamp : NSTimeInterval

  /// The acceleration of this point
  let userAcceleration : CMAcceleration
  
}
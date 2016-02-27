//
//  Runnable.swift
//  Runner
//
//  Created by Luciano Marisi on 27/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import Foundation

/**
 *  Protocol useful to execute any struct/class at a specific timestamp
 */
public protocol Runnable {
  var timestamp : NSTimeInterval { get }
}
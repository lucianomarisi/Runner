//
//  Motionable.swift
//  Runner
//
//  Created by Luciano Marisi on 27/02/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import CoreMotion

protocol Motionable {
  var rotationRate: CMRotationRate { get }
  var gravity: CMAcceleration { get }
  var userAcceleration: CMAcceleration { get }
}

extension Motionable {
  var rotationRate: CMRotationRate { return CMRotationRate() }
  var gravity: CMAcceleration { return CMAcceleration() }
  var userAcceleration: CMAcceleration { return CMAcceleration() }
}
# Dispatcher

[![Build Status](https://travis-ci.org/lucianomarisi/Dispatcher.svg?branch=master)](https://travis-ci.org/lucianomarisi/Dispatcher)
[![codecov.io](http://codecov.io/github/lucianomarisi/Dispatcher/coverage.svg?branch=master)](http://codecov.io/github/lucianomarisi/Dispatcher?branch=master)

Easily Dispatch points at specific time intervals.

## Installation

- Add the files inside the `Dispatcher` folder to your project

## Examples

### Dispatch a predefined set of points

```swift
// Generate some points
var mockPoints = [Point]()
let numberOfPoints = 10
let totalTime = 1.0
for index in 0...numberOfPoints {
  let timestamp = NSTimeInterval(index) * totalTime / Double(numberOfPoints)
  let mockPoint = Point(timestamp: timestamp, value: Double(index))
  mockPoints.append(mockPoint)
}

// Execute blocks at the times from the mocked points
let dispatcher = Dispatcher()
dispatcher.startWithMockPoints(mockPoints) { (point) -> Void in
  NSLog("\(point.value)")
}
```

### Dispatch a points using a function

```swift

// Define function to generate points
func sineSignal(nextTimestamp: NSTimeInterval) -> Point {
  let signalFrequency = 1.0
  let amplitude = 2.0
  let offset = 0.5
  let phaseShift = 0.2
  let value = amplitude * sin(nextTimestamp * signalFrequency + phaseShift) + offset
  return Point(timestamp: nextTimestamp, value: value)
}

let dispatcher = Dispatcher()
// Start dispatching points
dispatcher.startWithFunction(sineSignal) { (point) -> Void in
  NSLog("\(point.value)")
}

// Stop dispatching points
dispatcher.stop()
```

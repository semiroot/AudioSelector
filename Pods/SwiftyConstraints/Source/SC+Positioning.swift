//
//  SwiftyConstraint+Positioning.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Positioning constraint management
extension SwiftyConstraints {
  
  /// Creates a constraint centering the subview on the x axis of the superview
  ///
  /// - Parameter modiefiedBy: Float modifier
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
    open func center(_ multiplied: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.centerX, .equal, superview, .centerX, multiplied, modiefiedBy)
    } catch let error { reportError(error, "Center") }
    return self
  }
  
  /// Removes the center (x axis) constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeCenter() -> SwiftyConstraints {
    do {
      try deleteConstraint(.center)
    } catch let error { reportError(error, "RemoveCenter") }
    return self
  }
  
  /// Creates a constraint centering the subview on the y axis of the superview
  ///
  /// - Parameter modiefiedBy: Float modifier
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func middle(_ multiplied: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
        try createConstraint(.centerY, .equal, superview, .centerY, multiplied, modiefiedBy)
    } catch let error { reportError(error, "Middle") }
    return self
  }
  
  /// Removes the middle (y axis) constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeMiddle() -> SwiftyConstraints {
    do {
      try deleteConstraint(.middle)
    } catch let error { reportError(error, "RemoveMiddle") }
    return self
  }
  
  /// Disposes all stack references (top, right, bottom, left)
  ///
  /// Every subsequent positional constraints will reference the superview's again.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func resetStacks() -> SwiftyConstraints {
    previousTop = nil
    previousRight = nil
    previousBottom = nil
    previousLeft = nil
    return self
  }
}

//
//  SwiftyConstraints+Height.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Height constraint management
extension SwiftyConstraints {
  
  /// Creates a height constraint for the subview
  ///
  /// - Parameter equals: Float width (dpi)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func height(_ equals: Float) -> SwiftyConstraints {
    do {
      try createConstraint(.height, .equal, nil, .height, 0, equals)
    } catch let error { reportError(error, "Height") }
    return self
  }
  
  /// Creates a height constraint for the subview equal to the height of the referenced view
  ///
  /// Make sure the view you reference is already attached via SwiftyConstraints
  /// otherwise no constraint will be created.
  ///
  /// - Parameters:
  ///   - view: SCView referencing view
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func heightOf(_ view: SCView, _ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      let referenceContainer = try getExistingContainer(view)
      return heightOf(referenceContainer, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "HeightOf") }
    return self
  }
  
  /// Internal heightOf for use with SCContainer instead of SCView
  ///
  /// - Parameters:
  ///   - reference: SCContainer containing the referencing view
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  internal func heightOf(_ reference: SCContainer, _ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.height, .equal, reference.view, .height, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "HeightOf") }
    return self
  }
  
  /// Creates a height constraint for the subview equal to the height of the superview
  ///
  /// - Parameters:
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func heightOfSuperview(_ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.height, .equal, superview, .height, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "HeightOfSuperview") }
    return self
  }
  
  /// Creates a height constraint that is equal to the subview's width
  ///
  /// - Parameters:
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func heightFromWidth(_ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      let container = try getCurrentContainer()
      try createConstraint(.height, .equal, container.view, .width, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "HeightFromWidth") }
    return self
  }
  
  /// Removes the height constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeHeight() -> SwiftyConstraints {
    do {
      try deleteConstraint(.height)
    } catch let error { reportError(error, "RemoveHeight") }
    return self
  }
}

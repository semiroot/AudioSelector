//
//  SwiftyConstraints+Width.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Width constraint management
extension SwiftyConstraints {
  
  /// Creates a width constraint for the subview
  ///
  /// - Parameter equals: Float width (dpi)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func width(_ equals: Float) -> SwiftyConstraints {
    do {
      try createConstraint(.width, .equal, nil, .width, 0, equals)
    } catch let error { reportError(error, "Width") }
    return self
  }
  
  /// Creates a width constraint for the subview equal to the width of the referenced view
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
  open func widthOf(_ view: SCView, _ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      let referenceContainer = try getExistingContainer(view)
      return widthOf(referenceContainer, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "WidthOf") }
    return self
  }
  
  /// Internal widthOf for use with SCContainer instead of SCView
  ///
  /// - Parameters:
  ///   - reference: SCContainer containing the referencing view
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  internal func widthOf(_ reference: SCContainer, _ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.width, .equal, reference.view, .width, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "WidthOf") }
    return self
  }
  
  /// Creates a width constraint for the subview equal to the width of the superview
  ///
  /// - Parameters:
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func widthOfSuperview(_ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.width, .equal, superview, .width, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "WidthOfSuperview") }
    return self
  }
  
  /// Creates a width constraint that is equal to the subview's height
  ///
  /// - Parameters:
  ///   - multipliedBy: Float multiplier (1 is default)
  ///   - modiefiedBy: Float modifier (0 is default)
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func widthFromHeight(_ multipliedBy: Float = 1, _ modiefiedBy: Float = 0) -> SwiftyConstraints {
    do {
      let container = try getCurrentContainer()
      try createConstraint(.width, .equal, container.view, .height, multipliedBy, modiefiedBy)
    } catch let error { reportError(error, "WidthFromHeight") }
    return self
  }
  
  /// Removes the width constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeWidth() -> SwiftyConstraints {
    do {
      try deleteConstraint(.width)
    } catch let error { reportError(error, "RemoveWidth") }
    return self
  }
}

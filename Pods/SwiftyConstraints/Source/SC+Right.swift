//
//  SwiftyConstraints+Right.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Right constraint management
extension SwiftyConstraints {
  
  /// Creates a top constraint for the subview to the right of its superview
  ///
  ///	If there is a right stacked subview, this subview's right will match the left
  /// of the stacked subview using the 'rightOf' method.
  ///
  /// - Parameter margin: Float the right margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func right(_ margin: Float = 0) -> SwiftyConstraints {
    do {
      if let previousRight = previousRight {
        return rightOf(previousRight, margin)
      }
      try createConstraint(.right, .equal, superview, .right, 1, 0 - margin)
    } catch let error { reportError(error, "Right") }
    return self
  }
  
  /// Creates a right constraint for the subview to the left of the given subview
  ///
  /// Make sure the view you reference is already attached via SwiftyConstraints
  /// otherwise no constraint will be created.
  ///
  /// - Parameters:
  ///   - view: SCView the referencing view
  ///   - margin: Float the right margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func rightOf(_ view: SCView, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      let referenceContainer = try getExistingContainer(view)
      return rightOf(referenceContainer, margin)
    } catch let error { reportError(error, "RightOf") }
    return self
  }
  
  /// Internal rightOf for use with SCContainer instead of SCView
  ///
  /// - Parameters:
  ///   - reference: SCContainer of the referencing view
  ///   - margin: Float the right margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  internal func rightOf(_ reference: SCContainer, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.right, .equal, reference.view, .left, 1, 0 - margin)
    } catch let error { reportError(error, "RightOf") }
    return self
  }
  
  /// Removes the right constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeRight() -> SwiftyConstraints {
    do {
      try deleteConstraint(.right)
    } catch let error { reportError(error, "RemoveRight") }
    return self
  }
  
  /// Retains the subview as right stack reference
  ///
  /// Every subsequent right constraints will reference this subview's
  /// left position instead of the superview's right
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func stackRight() -> SwiftyConstraints {
    if let container = currentContainer {
      previousRight = container
    }
    return self
  }
  
  /// Disposes the right stack reference
  ///
  /// Every subsequent top constraints will reference the superview's right again.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func resetStackRight() -> SwiftyConstraints {
    previousRight = nil
    return self
  }
}

//
//  SwiftyConstraints+Left.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Left constraint management
extension SwiftyConstraints {
  
  /// Creates a top constraint for the subview to the left of its superview
  ///
  ///	If there is a left stacked subview, the subview's left will match the right
  /// of the stacked subview using the 'leftOf' method.
  ///
  /// - Parameter margin: Float the left margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func left(_ margin: Float = 0) -> SwiftyConstraints {
    do {
      if let previousLeft = previousLeft {
        return leftOf(previousLeft, margin)
      }
      try createConstraint(.left, .equal, superview, .left, 1, margin)
    } catch let error { reportError(error, "Left") }
    return self
  }
  
  /// Creates a left constraint for the subview to the right of the given subview
  ///
  /// Make sure the view you reference is already attached via SwiftyConstraints
  /// otherwise no constraint will be created.
  ///
  /// - Parameters:
  ///   - view: SCView the referencing view
  ///   - margin: Float the left margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func leftOf(_ view: SCView, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      let referenceContainer = try getExistingContainer(view)
      return leftOf(referenceContainer, margin)
    } catch let error { reportError(error, "LeftOf") }
    return self
  }
  
  /// Internal leftOf for use with SCContainer instead of SCView
  ///
  /// - Parameters:
  ///   - reference: SCContainer of the referencing view
  ///   - margin: Float the left margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  internal func leftOf(_ reference: SCContainer, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.left, .equal, reference.view, .right, 1, margin)
    } catch let error { reportError(error, "LeftOf") }
    return self
  }
  
  /// Removes the left constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeLeft() -> SwiftyConstraints {
    do {
      try deleteConstraint(.left)
    } catch let error { reportError(error, "RemoveLeft") }
    return self
  }
  
  /// Retains the subview as left stack reference
  ///
  /// Every subsequent left constraints will reference this subview's
  /// right position instead of the superview's left
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func stackLeft() -> SwiftyConstraints {
    if let container = currentContainer {
      previousLeft = container
    }
    return self
  }
  
  /// Disposes the left stack reference
  ///
  /// Every subsequent top constraints will reference the superview's left again.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func resetStackLeft() -> SwiftyConstraints {
    previousLeft = nil
    return self
  }
}

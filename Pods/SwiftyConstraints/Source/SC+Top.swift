//
//  SwiftyConstraints+Top.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Top constraint management
extension SwiftyConstraints {
  
  /// Creates a top constraint for the subview to the top of its superview
  ///
  ///	If there is a top stacked subview, this subview's top will match the bottom
  /// of the stacked subview using the 'below' method.
  ///
  /// - Parameter margin: Float the top margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func top(_ margin: Float = 0) -> SwiftyConstraints {
    do {
      if let previousTop = previousTop {
        return below(previousTop, margin)
      }
      try createConstraint(.top, .equal, superview, .top, 1, margin)
    } catch let error { reportError(error, "Top") }
    return self
  }
  
  /// Creates a top constraint for the subview to the bottom of the given subview
  ///
  /// Make sure the view you reference is already attached via SwiftyConstraints
  /// otherwise no constraint will be created.
  ///
  /// - Parameters:
  ///   - view: SCView the referencing view
  ///   - margin: Float the top margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func below(_ view: SCView, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      let referenceContainer = try getExistingContainer(view)
      return below(referenceContainer, margin)
    } catch let error { reportError(error, "Below") }
    return self
  }
  
  /// Internal below for use with SCContainer instead of SCView
  ///
  /// - Parameters:
  ///   - reference: SCContainer of the referencing view
  ///   - margin: Float the top margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  internal func below(_ reference: SCContainer, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.top, .equal, reference.view, .bottom, 1, margin)
    } catch let error { reportError(error, "Below") }
    return self
  }
  
  /// Removes the top constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeTop() -> SwiftyConstraints {
    do {
      try deleteConstraint(.top)
    } catch let error { reportError(error, "RemoveTop") }
    return self
  }
  
  /// Retains the subview as top stack reference
  ///
  /// Every subsequent top constraints will reference this subview's
  /// bottom position instead of the superview's top
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func stackTop() -> SwiftyConstraints {
    if let container = currentContainer {
      previousTop = container
    }
    return self
  }
  
  /// Disposes the top stack reference
  ///
  /// Every subsequent top constraints will reference the superview's top again.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func resetStackTop() -> SwiftyConstraints {
    previousTop = nil
    return self
  }
}

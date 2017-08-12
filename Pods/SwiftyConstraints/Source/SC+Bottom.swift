//
//  SwiftyConstraints+Bottom.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Bottom constraint management
extension SwiftyConstraints {
  
  /// Creates a top constraint for the subview to the bottom of its superview
  ///
  ///	If there is a bottom stacked subview, this subview's bottom will match the top
  /// of the stacked subview using the 'above' method.
  ///
  /// - Parameter margin: Float the bottom margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func bottom(_ margin: Float = 0) -> SwiftyConstraints {
    do {
      if let previousBottom = previousBottom {
        return above(previousBottom, margin)
      }
      try createConstraint(.bottom, .equal, superview, .bottom, 1, 0 - margin)
    } catch let error { reportError(error, "Bottom") }
    return self
  }
  
  /// Creates a bottom constraint for the subview to the top of the given subview
  ///
  /// Make sure the view you reference is already attached via SwiftyConstraints
  /// otherwise no constraint will be created.
  ///
  /// - Parameters:
  ///   - view: SCView the referencing view
  ///   - margin: Float the bottom margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func above(_ view: SCView, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      let referenceContainer = try getExistingContainer(view)
      return above(referenceContainer, margin)
    } catch let error { reportError(error, "Above") }
    return self
  }
  
  /// Internal above for use with SCContainer instead of SCView
  ///
  /// - Parameters:
  ///   - reference: SCContainer of the referencing view
  ///   - margin: Float the bottom margin of the subview
  /// - Returns: SwiftyConstraints for method chaining
  internal func above(_ reference: SCContainer, _ margin: Float = 0) -> SwiftyConstraints {
    do {
      try createConstraint(.bottom, .equal, reference.view, .top, 1, 0 - margin)
    } catch let error { reportError(error, "Above") }
    return self
  }
  
  /// Removes the bottom constraint for this subview
  ///
  /// Only the constraint will be removed.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeBottom() -> SwiftyConstraints {
    do {
      try deleteConstraint(.bottom)
    } catch let error { reportError(error, "RemoveBottom") }
    return self
  }
  
  /// Retains the subview as bottom stack reference
  ///
  /// Every subsequent bottom constraints will reference this subview's
  /// top position instead of the superview's bottom
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func stackBottom() -> SwiftyConstraints {
    if let container = currentContainer {
      previousBottom = container
    }
    return self
  }
  
  /// Disposes the bottom stack reference
  ///
  /// Every subsequent top constraints will reference the superview's bottom again.
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func resetStackBottom() -> SwiftyConstraints {
    previousBottom = nil
    return self
  }
}

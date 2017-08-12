//
//  SwiftyConstraints+Helper.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

// MARK: Helpers
extension SwiftyConstraints {
  
  /// Forces the layout to be recalculated
  ///
  /// This is particularly helpfull when intrisic sizes have to be recalculated e.g.:
  /// A textview getting a width constraint that impacts it's height and relying constraints.
  ///
  /// 'layoutIfNeeded' functionality is used internaly
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func updateConstraints() -> SwiftyConstraints {
    do {
      let superview = try getSuperview()
      
      #if os(iOS)
        superview.layoutIfNeeded()
        for container in containers {
          container.view?.layoutIfNeeded()
        }
        
      #elseif os(OSX)
        superview.updateConstraintsForSubtreeIfNeeded()
        superview.layoutSubtreeIfNeeded()
        
      #endif
      
    } catch let error { reportError(error, "UpdateConstraints") }
    return self
  }
  
  /// Convinience method to execute code in the method chain flow
  ///
  /// The current view will be passed to the closure
  ///
  /// - Parameter closure: closure to execute
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func execute(_ closure: (_ view: SCView) -> Void) -> SwiftyConstraints {
    do {
      let container = try getCurrentContainer()
      guard let view = container.view else { throw SCError.emptySubview }
      closure(view)
    } catch let error { reportError(error, "Execute") }
    return self
  }
}

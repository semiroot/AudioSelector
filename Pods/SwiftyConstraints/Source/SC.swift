//
//  SwiftyConstraints.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 20/03/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

#if os(iOS)
  import UIKit
  
#elseif os(OSX)
  import AppKit
  
#endif


/// A helper to create, modify and remove layout constraints for NSViews and UIViews
open class SwiftyConstraints {
  
  internal private(set) weak var superview: SCView?
  internal var containers = [SCContainer]()
  internal var currentContainer: SCContainer?
  
  internal var previousTop: SCContainer?
  internal var previousRight: SCContainer?
  internal var previousBottom: SCContainer?
  internal var previousLeft: SCContainer?
  
  public private(set) var previousErrors = [SCError]()
  
  /// Initializes a new SwiftyConstraint with the given view as main view
  /// This will change translatesAutoresizingMaskIntoConstraints to false for this view
  ///
  /// - Parameter withsuperview: UIView/NSView the main view to work with
  public init(_ superview: SCView) {
    self.superview = superview
  }

  
  // MARK: internals
  
  /// Safe getter for the superview
  ///
  /// - Returns: SCView superview
  /// - Throws: SCError.emptySuperview if inexistent
  internal func getSuperview() throws -> SCView {
    guard let superview = self.superview else {
      throw SCError.emptySuperview
    }
    return superview
  }
  
  /// Safe getter for the superview
  ///
  /// - Returns: the current SCContainer
  /// - Throws: SCError.emptySubview if container or view is inexistent
  internal func getCurrentContainer() throws -> SCContainer {
    // TODO remove the view check and move it to the container
    guard let currentContainer = self.currentContainer, currentContainer.view != nil else {
      throw SCError.emptySubview
    }
    return currentContainer
  }
  
  /// Safe getter for an existing container
  ///
  /// - Parameter view: the view to find the container by
  /// - Returns: SCContainer
  /// - Throws: SCError.emptyReferenceView if no container for the view exists
  internal func getExistingContainer(_ view: SCView) throws -> SCContainer {
    guard let existingIndex = containers.index(where: {$0.view === view}) else {
      throw SCError.emptyReferenceView
    }
    return containers[existingIndex]
  }
  
  /// Creates a new NSLayoutConstraint for the current view and adds it to the superview
  /// The constraint will be stored in the container automatically
  ///
  /// - Parameters:
  ///   - fromAttribute: NSLayoutAttribute
  ///   - relatedBy: NSLayoutRelation
  ///   - toItem: SCView? referencing view
  ///   - toAttribute: NSLayoutAttribute
  ///   - multiplier: multiplier
  ///   - constant: constant
  /// - Throws: SCError (multiple possible)
  internal func createConstraint(_ fromAttribute: NSLayoutAttribute, _ relatedBy: NSLayoutRelation, _ toItem: SCView?, _ toAttribute: NSLayoutAttribute, _ multiplier: Float, _ constant: Float) throws {
    let superview = try getSuperview()
    let currentContainer = try getCurrentContainer()
    guard let fromView = currentContainer.view else { throw SCError.emptySubview }
    let attributeKey = try SCAttribute.translate(fromAttribute)
    
    if currentContainer.get(attributeKey) != nil {
      throw SCError.doubleConstraint
    }
    
    let constraint = NSLayoutConstraint(
      item: fromView,
      attribute: fromAttribute,
      relatedBy: relatedBy,
      toItem: toItem,
      attribute: toAttribute,
      multiplier: CGFloat(multiplier),
      constant: CGFloat(constant)
    )
    
    currentContainer.set(attributeKey, constraint)
    
    superview.addConstraint(constraint)
  }
  
  /// Removes a NSLayoutConstraint for the current subview from the superview
  ///
  /// - Parameter attribute: SCAttribute to remove
  /// - Throws: SCError (multiple)
  internal func deleteConstraint(_ attribute: SCAttribute) throws {
    let superView = try getSuperview()
    let container = try getCurrentContainer()
    guard let constraint = container.get(attribute) else { throw SCError.emptyRemoveConstraint }
    superView.removeConstraint(constraint)
    container.set(attribute, nil)
  }
  
  internal func reportError(_ error: Error, _ message: String?) {
    if let scError = error as? SCError {
      previousErrors.append(scError)
      scError.report(superview, currentContainer?.view, message)
    }
  }
  
  
  // MARK: Subview management
  
  /// Attaches a new subview and sets the working item to the given subview
  ///
  /// After this call, all subsequent calls to constraint methods affect only this subview.
  ///
  /// Attching a view will change its translatesAutoresizingMaskIntoConstraints settings and add the view as subview of the superview.
  /// If the given view has already been added, 'work' will be used to point to that
  ///
  /// - Parameter subview: SCView subview to attach
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func attach(_ subview: SCView) -> SwiftyConstraints {
    do {
      let superview = try getSuperview()
      if (try? getExistingContainer(subview)) != nil {
        return use(subview)
      } else {
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        
        currentContainer = SCContainer(subview)
        containers.append(currentContainer!)
      }
    } catch let error { reportError(error, "Attach") }
    return self
  }
  
  /// Sets the working item to the given subview
  ///
  /// After this call, all subsequent calls to constraint methods affect only this subview.
  ///
  /// This method can only work if the given view has been previsously attached!
  /// If it has not, nothing will change and SwiftyConstraints will work with the previous view.
  ///
  /// - Parameter with: SCView to work with
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func use(_ withSubview: SCView) -> SwiftyConstraints {
    do {
      let existing = try getExistingContainer(withSubview)
      currentContainer = existing
    } catch let error { reportError(error, "Work") }
    return self
  }
  
  /// Removes the current subview from its superview and removes all constraints
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func remove() -> SwiftyConstraints {
    do {
      let container = try getCurrentContainer()
      let superview = try getSuperview()
      if let constraints = container.constraintList() {
        superview.removeConstraints(constraints)
        container.resetConstraints()
      }
      container.view?.removeFromSuperview()
      containers = containers.filter { $0.view != container.view }
      currentContainer = nil
    } catch let error { reportError(error, "Remove") }
    return self
  }
  
  /// Removes all subiews and all teir constraints from the superview
  ///
  /// - Returns: SwiftyConstraints for method chaining
  @discardableResult
  open func removeAll() -> SwiftyConstraints {
    for container in containers {
      if let constraints = container.constraintList(), let superview = self.superview {
        superview.removeConstraints(constraints)
        container.resetConstraints()
      }
      container.view?.removeFromSuperview()
    }
    
    containers = [SCContainer]()
    currentContainer = nil
    
    return self
  }
}

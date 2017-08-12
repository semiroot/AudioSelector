//
//  SCContainer.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 14/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

#if os(iOS)
  import UIKit
  
#elseif os(OSX)
  import AppKit
  
#endif


/// Represents a view and its layout constraints
internal class SCContainer {
  
  internal fileprivate(set) weak var view: SCView?
  private var constraintStorage = [SCAttribute: NSLayoutConstraint]()
  
  /// Initializer
  ///
  /// - Parameter subview: the view this container is for
  init(_ subview: SCView) { view = subview }
  
  /// Returns the NSLayoutConstraint for the indicated attribute
  ///
  /// - Parameter key: SCAttribute key
  /// - Returns: NSLayoutConstraint or nil if it does not exist
  internal func get(_ key: SCAttribute) -> NSLayoutConstraint? {
    return constraintStorage[key]
  }
  
  /// Sets or removes (supply nil as value) the NSLayoutConstraint for the indicated attribute
  ///
  /// - Parameters:
  ///   - key: SCAttribute key
  ///   - value: the new NSLyoutConstraint or nil (to remove)
  /// - Returns: returns true if there was a modification (false on existing value or empty removal)
  @discardableResult
  internal func set(_ key: SCAttribute, _ value: NSLayoutConstraint?) -> Bool {
    if let value = value {
      return constraintStorage.updateValue(value, forKey: key) != value
    } else {
      return constraintStorage.removeValue(forKey: key) != nil
    }
  }
  
  /// Returns a list of constraints for this view
  ///
  /// - Returns: returns a list of NSLayoutConstraint or nil if there aren't any
  internal func constraintList() -> [NSLayoutConstraint]? {
    var cList = [NSLayoutConstraint]()
    for (_, value) in constraintStorage {
      cList.append(value)
    }
    return cList.count > 0 ? cList : nil
  }
  
  /// Removes all references to the constraints
  /// Warning: This will not remove or delete any constraint from any view
  internal func resetConstraints() {
    constraintStorage.removeAll()
  }
}

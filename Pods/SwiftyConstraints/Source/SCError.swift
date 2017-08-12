//
//  SCError.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 14/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//


/// Internal error definition
///
/// - emptySuperview: The superview is nil
/// - emptySubview: the current subview or container is nil
/// - emptyReferenceView: the referencing view is nil
/// - emptyRemoveConstraint: empty constraint was tried to remove
/// - doubleConstraint: constraint for attribute already exists
/// - internalError: Upps
public enum SCError: Error {
  
  case emptySuperview
  case emptySubview
  case emptyReferenceView
  case emptyRemoveConstraint
  case doubleConstraint
  case internalError
  
  /// Prints a detailed error to console if SCDEBUG is set
  ///
  /// - Parameters:
  ///   - superview: SCView? patentview
  ///   - subview: SCView? childview
  ///   - constraint: String? Constraint description
  internal func report(_ superview: SCView?, _ subview: SCView?, _ constraint: String?) {
    #if SCDEBUG
      var message = ""
      var hint = ""
      
      switch self {
      case .emptySuperview:
        message += "Skipped constraint as there is no main view to attach a constraint to:"
        hint += "The main view might not exist anymore. Did you store the right SwiftyConstraint handler?"
      case .emptySubview:
        message += "Skipped constraint as there is no subview to work with:"
        hint += "Did you mean to use 'attach' or 'work' to set a subview to work with?"
      case .emptyReferenceView:
        message += "Skipped constraint as the referenced view does not exist:"
        hint += "Did you attach the view before using it together with another constraint?"
      case .doubleConstraint:
        message += "Skipped constraint as there is already an existing constraint:"
        hint += "Use the according 'removeConstraint' method before adding a new one."
      case .emptyRemoveConstraint:
        message += "Skipped constraint removal as there is none stored for this view:"
        hint += "Are you using the right removeConstraint method?"
      default:
        message += "Skipped constraint as there was an internal error:"
        hint += "Sorry about that! Please report this bug to https://github.com/semiroot/SwiftyConstraints/issues Thank you!"
      }
      
      if let superview = superview {
        message += "\n Superview: \(superview.self)"
      }
      if let subview = subview {
        message += "\n Subview: \(subview.self)"
      }
      if let constraint = constraint {
        message += "\n Constraint: \(constraint)"
      }
      message += "\n Hint: \(hint)"
      
      print("SwiftyConstraints: \(message)\n")
    #endif
  }
}

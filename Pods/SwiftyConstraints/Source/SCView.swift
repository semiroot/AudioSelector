//
//  SwiftyConstraintsView.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 15/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

#if os(iOS)
  import UIKit
  public typealias SCView = UIView
  
#elseif os(OSX)
  import AppKit
  public typealias SCView = NSView
  
#endif


// MARK: - Extension for NSView/UIView
extension SCView {
  
  /// Returns a new SwiftyConstraints object working with the view
  /// Note: No reference is stored! If you wish to reuse this instance store it!
  ///
  /// - Returns: A new SwiftyConstraints object base on this view
  public func swiftyConstraints() -> SwiftyConstraints {
    return SwiftyConstraints(self)
  }
}

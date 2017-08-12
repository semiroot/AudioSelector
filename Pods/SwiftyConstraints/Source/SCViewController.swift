//
//  SCExtensions.swift
//  SwiftyConstraints
//
//  Created by Hansmartin Geiser on 14/04/17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

#if os(iOS)
  import UIKit
  public typealias SCViewController = UIViewController
  
#elseif os(OSX)
  import AppKit
  public typealias SCViewController = NSViewController
  
#endif


// MARK: - Extension for NSViewController/UIViewController
extension SCViewController {
  
  /// Returns a new SwiftyConstraints object working with the current view of this controller
  /// Note: No reference is stored! If you wish to reuse this instance store it!
  ///
  /// - Returns: A new SwiftyConstraints object base on current controllers view
  public func swiftyConstraints() -> SwiftyConstraints {
    return SwiftyConstraints(self.view)
  }
}

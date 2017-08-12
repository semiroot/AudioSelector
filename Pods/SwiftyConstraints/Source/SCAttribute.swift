//
//  SCAttribute.swift
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


/// Possible positioning attributes
///
/// - top: top alignment
/// - right: right alignment
/// - bottom: bottom alignment
/// - left: left alignment
/// - width: width of view
/// - height: height of view
/// - center: X axis positioning
/// - middle: Y axis positioning
public enum SCAttribute {
  case top
  case right
  case bottom
  case left
  case width
  case height
  case center
  case middle
  
  /// Translates NSLayoutAttribute to SCAttribute
  /// Note: not all of the NSLayoutAttribute are supported
  ///
  /// - Parameter attributeName: NSLayoutAttribute name
  /// - Returns: SCAttribute
  /// - Throws: SCError.internalError for unsupported NSLayoutAttribute names
  public static func translate(_ attributeName: NSLayoutAttribute) throws -> SCAttribute {
    switch attributeName {
    case .top: return .top
    case .right: return .right
    case .bottom: return .bottom
    case .left: return .left
    case .width: return .width
    case .height: return .height
    case .centerX: return .center
    case .centerY: return .middle
    default:
      throw SCError.internalError
    }
  }
}

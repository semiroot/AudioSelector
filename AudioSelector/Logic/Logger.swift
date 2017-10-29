//
//  Logger.swift
//  AudioSelector
//
//  Created by Semiotikus on 29.10.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Foundation
import RxSwift

class Logger {
    public static let shared = Logger()
    
    public var printEntries = true
    public var entries = Variable("")
    
    public func add(_ entry: Any) {
        let data = String(describing: entry)
        if printEntries { Swift.print(data) }
        entries.value = "\(data)\n\(entries.value)"
    }
}

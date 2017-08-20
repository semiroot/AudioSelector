//
//  InterfaceRequest.swift
//  AudioSelector
//
//  Created by Semiotikus on 13.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Foundation

enum InterfaceAction {
    case setAsInput
    case setAsOutput
    case setAsSystem
    
    case setAsDefaultInput
    case setAsDefaultOutput
    case setAsDefaultSystem
    
    case setVolumeIn(Float32)
    case setVolumeOut(Float32)
    case setVolumeMasterOut(Float32)
}

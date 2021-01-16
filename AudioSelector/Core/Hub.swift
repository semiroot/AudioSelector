//
//  InterfaceRequest.swift
//  AudioSelector
//
//  Created by Semiotikus on 13.08.17.
//  Copyright © 2017 Hansmartin Geiser. All rights reserved.
//

import Foundation
import RxSwift
import AMCoreAudio

class Hub {
    
    private static var observable: Observable<Message>?
    private static var publishable = PublishSubject<Message>()
    
    static var requests: Observable<Message> {
        if observable == nil { observable = publishable }
        return observable!
    }
    
    static func request(_ request: Message) {
        DispatchQueue.main.async {
            publishable.onNext(request)
        }
        
    }
    
    static func log(_ content: Any) {
    #if DEBUG
        let data = String(describing: content)
        Swift.print(data)
        publishable.onNext(.log(data))
    #endif
    }
}

enum Message {
    case updateFacades
    case updateInputFacades
    case updateOutputFacades
    case updateSystemFacades
    case updateFacade(AudioDevice)
    case updateAppIcon(Bool)
    case togglePassthrough
    case startPassthrough
    case stopPassthrough
    case populate
    case log(String)
}

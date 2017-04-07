//
//  KeyChainMessenger.swift
//  ApplicationGroupKit
//
//  Created by phimage on 01/02/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import Prephirences

open class KeyChainMessenger: PreferencesMessenger {
    let service: String

    public init(service: String) {
        self.service = service
        super.init()
    }

    open override var preferences: MutablePreferencesType? {
        return self.applicationGroup?.keyChain(service)
    }

    open override var type: MessengerType {
        return .keyChain(service: self.service)
    }

    override func checkConfig() -> Bool {
        return preferences != nil
    }

}

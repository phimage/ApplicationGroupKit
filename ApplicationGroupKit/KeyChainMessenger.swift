//
//  KeyChainMessenger.swift
//  ApplicationGroupKit
//
//  Created by phimage on 01/02/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import Prephirences

public class KeyChainMessenger: PrepherencesMessenger {
    let service: String

    public init(service: String) {
        self.service = service
        super.init()
    }

    public override var preferences: MutablePreferencesType? {
        return self.applicationGroup?.keyChain(service)
    }

    public override var type: MessengerType {
        return .KeyChain(service: self.service)
    }

    override func checkConfig() -> Bool {
        return preferences != nil
    }

}
//
//  ApplicationGroup+Prephirences.swift
//  ApplicationGroupKit
//
//  Created by phimage on 03/02/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import Prephirences

extension ApplicationGroup: MutablePreferencesType {

    public func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.messageForIdentifier(key)
    }

    public func dictionary() -> PreferencesDictionary {
        return self.messages ?? [:]
    }

    public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        if let message = value as? Message {
            self.postMessage(message, withIdentifier: key)
        } else {
            self.removeObject(forKey: key)
        }
    }

    public func removeObject(forKey key: PreferenceKey) {
        do {
            try self.clearForIdentifier(key)
        } catch let e {
            print("Failed to remove key \(key): \(e)")
        }
    }

}

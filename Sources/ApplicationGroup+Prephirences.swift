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

    public func object(forKey key: String) -> Any? {
        return self.message(forIdentifier: key)
    }

    public func dictionary() -> [String : Any] {
        return self.messages ?? [:]
    }

    public func set(_ value: Any?, forKey key: String) {
        if let message = value as? Message {
            self.post(message: message, withIdentifier: key)
        } else {
            self.removeObject(forKey: key)
        }
    }

    public func removeObject(forKey key: String) {
        do {
            try self.clear(forIdentifier: key)
        } catch let e {
            print("Failed to remove key \(key): \(e)")
        }
    }

}

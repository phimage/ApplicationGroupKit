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

    public func objectForKey(key: String) -> AnyObject? {
        return self.messageForIdentifier(key)
    }

    public func dictionary() -> [String : AnyObject] {
        return self.messages ?? [:]
    }

    public func setObject(value: AnyObject?, forKey key: String) {
        if let message = value as? Message {
            self.postMessage(message, withIdentifier: key)
        } else {
            self.removeObjectForKey(key)
        }
    }

    public func removeObjectForKey(key: String) {
        do {
            try self.clearForIdentifier(key)
        } catch let e {
            print("Failed to remove key \(key): \(e)")
        }
    }

}
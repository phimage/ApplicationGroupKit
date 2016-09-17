//
//  PrepherencesMessenger.swift
//  ApplicationGroupKit
//
//  Created by phimage on 03/02/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import Prephirences

open class PrepherencesMessenger: Messenger {
    
    open var preferences: MutablePreferencesType? {
        fatalError("Must be overrided")
    }
    
    open override var type: MessengerType {
        fatalError("Must be overrided")
        // return .Custom(self)
    }
    
    override func checkConfig() -> Bool {
        return preferences != nil
    }

    override func write(message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        let data = PrepherencesMessenger.data(fromMessage: message)
        guard let preferences = self.preferences else {
            return false
        }
        preferences.set(data, forKey: identifier)
        return true
    }

    override func readMessage(forIdentifier identifier: MessageIdentifier) -> Message? {
        guard let data = self.preferences?.object(forKey: identifier) as? Data else {
            return nil
        }
        return PrepherencesMessenger.message(fromData: data)
    }

    override func deleteContent(forIdentifier identifier: MessageIdentifier) throws {
        self.preferences?.removeObject(forKey: identifier)
    }

    override func deleteContentForAllMessageIdentifiers() throws {
        if let keys = self.preferences?.dictionary().keys {
            for key in keys {
                self.preferences?.removeObject(forKey: key)
            }
        }
    }
    
    override func readMessages() -> [MessageIdentifier: Message]? {
        guard let preferences = self.preferences else {
            return nil
        }
        
        let messageLists = preferences.dictionary().filter { $0.1 is Message }
        return Dictionary(messageLists) as? [MessageIdentifier: Message]
    }
    
}

extension Dictionary {
    
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
}

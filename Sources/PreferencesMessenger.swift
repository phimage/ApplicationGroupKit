//
//  PreferencesMessenger.swift
//  ApplicationGroupKit
//
//  Created by phimage on 03/02/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import Prephirences

// abstract class
open class PreferencesMessenger: Messenger {

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

    override func writeMessage(_ message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        let data = dataFromMessage(message)
        guard let preferences = self.preferences else {
            return false
        }
        preferences.set(data, forKey: identifier)
        return true
    }

    override func readMessageForIdentifier(_ identifier: MessageIdentifier) -> Message? {
        guard let data = self.preferences?.object(forKey: identifier) as? Data else {
            return nil
        }
        return messageFromData(data)
    }

    override func deleteContentForIdentifier(_ identifier: MessageIdentifier) throws {
        self.preferences?.removeObject(forKey:identifier)
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

        var messageLists: [MessageIdentifier: Message] = [:]
        for (identifier, message) in preferences.dictionary() {
            if let message = message as? Message {
                messageLists[identifier] = message
            }
        }
        return messageLists
    }

}

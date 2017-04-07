//
//  ApplicationGroup.swift
//  ApplicationGroupKit
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import Prephirences

public typealias ApplicationGroupIdentifier = String

// An application group object, defined by its identifier and the way to transfert the message
open class ApplicationGroup {

    open let identifier: ApplicationGroupIdentifier
    open let messenger: Messenger

    public init?(identifier: ApplicationGroupIdentifier, messengerType: MessengerType = .file(directory: "appgroup")) {
        self.identifier = identifier
        switch messengerType {
        case .userDefaults:
            self.messenger = UserDefaultsMessenger()
        case .file(let directory):
            self.messenger = FileMessenger(directory: directory)
        case .fileCoordinator(let directory, let fileCoordinator):
            self.messenger = FileCoordinatorMessenger(directory: directory, fileCoordinator: fileCoordinator)
        case .keyChain(let service):
            self.messenger = KeyChainMessenger(service: service)
        case .custom(let messenger):
            self.messenger = messenger
        }
        self.messenger.applicationGroup = self

        if !self.messenger.checkConfig() {
            return nil
        }
    }

    // Post a message
    open func postMessage(_ message: Message, withIdentifier identifier: MessageIdentifier) {
        self.messenger.postMessage(message, withIdentifier: identifier)
    }

    // Observe message
    open func observeMessageForIdentifier(_ identifier: MessageIdentifier, closure: @escaping (Message) -> Void ) -> MessageObserver {
        return self.messenger.observeMessageForIdentifier(identifier, closure: closure)
    }

    // Get current message value if any
    open func messageForIdentifier(_ identifier: MessageIdentifier) -> Message? {
        return self.messenger.messageForIdentifier(identifier)
    }

    // Clear value for this identifier
    open func clearForIdentifier(_ identifier: MessageIdentifier) throws {
        try self.messenger.deleteContentForIdentifier(identifier)
    }

    // Clear for all message identifiers
    open func clearAll() throws {
        try self.messenger.deleteContentForAllMessageIdentifiers()
    }

    // Clear for all message identifiers
    open var messages: [MessageIdentifier: Message]? {
        return self.messenger.readMessages()
    }

    // MARK: factory of foundation objects

    // create a grooup user defaults
    open var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: self.identifier)
    }

    // get the url for group ip
    open func containerURLForSecurity(_ fileManager: FileManager = FileManager.default) -> URL? {
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: self.identifier)
    }

    // get keychain object

    open func keyChain(_ service: String) -> KeychainPreferences {
        let keyChain = KeychainPreferences(service: service)
        keyChain.accessGroup = self.identifier
        return keyChain
    }

    // TODO  WatchKit
}

extension ApplicationGroup: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: type(of: self)))(' \(self.identifier ), \(String(describing: self.messenger.type))')"
    }
}

// WIP: allow use subscript, but not released to see if could be compatible with Prephirences
extension ApplicationGroup {

    internal subscript(messageIdentifier: MessageIdentifier) -> Message? {
        get {
            return messageForIdentifier(messageIdentifier)
        }
        set {
            if let message = newValue {
                postMessage(message, withIdentifier: messageIdentifier)
            } else {
                do {
                    try clearForIdentifier(identifier)
                } catch {
                    print("Failed to clear group \(self) for message identifier \(identifier)")
                }
            }
        }
    }
}

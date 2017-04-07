//
//  Messenger.swift
//  ApplicationGroupKit
//
//  Created by phimage on 05/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation

// Object to send
public typealias Message = NSCoding
// Key/identifier of message
public typealias MessageIdentifier = String

// Object returned when starting to listen to app group message used to cancel observation
open class MessageObserver: NSObject {
    open var messenger: Messenger
    open var identifier: String

    init(messenger: Messenger, identifier: String) {
        self.messenger = messenger
        self.identifier = identifier
    }

}

// Abtract class which define how to send message and listen to it
open class Messenger {

    var applicationGroup: ApplicationGroup?

    init() {
    }

    open func postMessage(_ message: Message, withIdentifier identifier: MessageIdentifier) {
        assert(!identifier.isEmpty)
        if writeMessage(message, forIdentifier: identifier) {
            DarwinNotificationCenter.defaultCenter.post(name: identifier)
        }
    }

    open func observeMessageForIdentifier(_ identifier: MessageIdentifier, closure: @escaping (Message) -> Void ) -> MessageObserver {
        let listener = MessageObserver(messenger: self, identifier: identifier)
        DarwinNotificationCenter.defaultCenter.addObserver(for: identifier, object: listener) { () -> Void in
            if let message = self.readMessageForIdentifier(identifier) {
                closure(message)
            }
        }
        return listener
    }

    open func removeObserver(_ observer: MessageObserver) {
        DarwinNotificationCenter.defaultCenter.remove(observer: observer)
    }

    open func messageForIdentifier(_ identifier: MessageIdentifier) -> Message? {
        assert(!identifier.isEmpty)
        return self.readMessageForIdentifier(identifier)
    }

    internal func dataFromMessage(_ message: Message) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: message)
    }

    internal func messageFromData(_ data: Data) -> Message? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Message
    }

    // MARK: abstracts
    open var type: MessengerType {
        fatalError("must be overrided")
    }
    func checkConfig() -> Bool {
        fatalError("must be overrided")
    }

    func writeMessage(_ message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        fatalError("must be overrided")
    }

    func readMessageForIdentifier(_ identifier: MessageIdentifier) -> Message? {
        fatalError("must be overrided")
    }

    func deleteContentForIdentifier(_ identifier: MessageIdentifier) throws {
        fatalError("must be overrided")
    }

    func deleteContentForAllMessageIdentifiers() throws {
        fatalError("must be overrided")
    }

    func readMessages() -> [MessageIdentifier: Message]? {
        fatalError("must be overrided")
    }
}

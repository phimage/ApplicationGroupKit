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
public class MessageObserver: NSObject {
    public var messenger: Messenger
    public var identifier: String
    
    init(messenger: Messenger, identifier: String) {
        self.messenger = messenger
        self.identifier = identifier
    }
    
}

// Abtract class which define how to send message and listen to it
public class Messenger {
    
    var applicationGroup: ApplicationGroup?
    
    init() {
    }
    
    public func postMessage(message: Message, withIdentifier identifier: MessageIdentifier) {
        assert(!identifier.isEmpty)
        if writeMessage(message, forIdentifier: identifier)  {
            DarwinNotificationCenter.defaultCenter.postNotificationName(identifier)
        }
    }
    
    public func observeMessageForIdentifier(identifier: MessageIdentifier, closure: (Message) -> Void ) -> MessageObserver {
        let listener = MessageObserver(messenger: self, identifier: identifier)
        DarwinNotificationCenter.defaultCenter.addObserverForName(identifier, object: listener) { () -> Void in
            if let message = self.readMessageForIdentifier(identifier) {
                closure(message)
            }
        }
        return listener
    }
    
    public func removeObserver(observer: MessageObserver) {
        DarwinNotificationCenter.defaultCenter.removeObserver(observer)
    }
    
    public func messageForIdentifier(identifier: MessageIdentifier) -> Message? {
        assert(!identifier.isEmpty)
        return self.readMessageForIdentifier(identifier)
    }
    
    // MARK: abstracts
    func checkConfig() -> Bool {
        fatalError("must be overrided")
    }
    
    func writeMessage(message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        fatalError("must be overrided")
    }
    
    func readMessageForIdentifier(identifier: MessageIdentifier) -> Message? {
        fatalError("must be overrided")
    }
    
    func deleteContentForIdentifier(identifier: MessageIdentifier) throws {
        fatalError("must be overrided")
    }
    
    func deleteContentForAllMessageIdentifiers() throws {
        fatalError("must be overrided")
    }
}

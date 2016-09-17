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
    
    open func post(message: Message, withIdentifier identifier: MessageIdentifier) {
        assert(!identifier.isEmpty)
        if write(message: message, forIdentifier: identifier)  {
            DarwinNotificationCenter.defaultCenter.postNotification(name: identifier)
        }
    }
    
    open func observeMessage(forIdentifier identifier: MessageIdentifier, closure: @escaping (Message) -> Void ) -> MessageObserver {
        let listener = MessageObserver(messenger: self, identifier: identifier)
        DarwinNotificationCenter.defaultCenter.addObserver(name: identifier, object: listener) { () -> Void in
            if let message = self.readMessage(forIdentifier: identifier) {
                closure(message)
            }
        }
        return listener
    }
    
    open func remove(observer: MessageObserver) {
        DarwinNotificationCenter.defaultCenter.remove(observer: observer)
    }
    
    open func message(forIdentifier identifier: MessageIdentifier) -> Message? {
        assert(!identifier.isEmpty)
        return self.readMessage(forIdentifier: identifier)
    }
    
    // MARK: abstracts
    open var type: MessengerType {
        fatalError("must be overrided")
    }
    func checkConfig() -> Bool {
        fatalError("must be overrided")
    }
    
    func write(message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        fatalError("must be overrided")
    }
    
    func readMessage(forIdentifier identifier: MessageIdentifier) -> Message? {
        fatalError("must be overrided")
    }
    
    func deleteContent(forIdentifier identifier: MessageIdentifier) throws {
        fatalError("must be overrided")
    }
    
    func deleteContentForAllMessageIdentifiers() throws {
        fatalError("must be overrided")
    }
    
    func readMessages() -> [MessageIdentifier: Message]? {
        fatalError("must be overrided")
    }
}

extension Messenger {
    
    internal class func data(fromMessage message: Message) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: message)
    }
    
    internal class func message(fromData data: Data) -> Message? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Message
    }
}

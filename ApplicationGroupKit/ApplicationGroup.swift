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

public typealias ApplicationGroupIdentifier = String

// An application group object, defined by its identifier and the way to transfert the message
public class ApplicationGroup {
    
    public let identifier: ApplicationGroupIdentifier
    public let messenger: Messenger
    
    public init?(identifier: ApplicationGroupIdentifier, messengerType: MessengerType = .File) {
        self.identifier = identifier
        switch messengerType {
        case .UserDefaults:
            self.messenger = Messenger()
        case .File:
            self.messenger = FileMessenger()
        case .Custom(let messenger):
            self.messenger = messenger
        }
        self.messenger.applicationGroup = self
        
        if !self.messenger.checkConfig() {
            return nil
        }
    }

    // Post a message
    public func postMessage(message: Message, withIdentifier identifier: MessageIdentifier) {
        self.messenger.postMessage(message, withIdentifier: identifier)
    }
    
    // Observe message
    public func observeMessageForIdentifier(identifier: MessageIdentifier, closure: (Message) -> Void ) -> MessageObserver {
        return self.messenger.observeMessageForIdentifier(identifier, closure: closure)
    }
    
    // Get current message value if any
    public func messageForIdentifier(identifier: MessageIdentifier) -> Message? {
        return self.messenger.messageForIdentifier(identifier)
    }
    
    // Clear value for this identifier
    public func clearForIdentifier(identifier: MessageIdentifier) throws {
        try self.messenger.deleteContentForIdentifier(identifier)
    }
    
    // Clear for all message identifiers
    public func clearAll() throws {
        try self.messenger.deleteContentForAllMessageIdentifiers()
    }

    // MARK: factory of foundation objects
    public var userDefaults: NSUserDefaults? {
        return NSUserDefaults(suiteName: self.identifier)
    }
    
    public func containerURLForSecurity(fileManager: NSFileManager = NSFileManager.defaultManager()) -> NSURL? {
        return fileManager.containerURLForSecurityApplicationGroupIdentifier(self.identifier)
    }

    // TODO KeyChain, FileCoordinator, WatchKit
}








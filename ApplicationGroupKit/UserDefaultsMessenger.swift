//
//  UserDefaultsMessenger.swift
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

public class UserDefaultsMessenger: Messenger {
    
    public override init() {
        super.init()
    }
    
    public override var type: MessengerType {
        return .UserDefaults
    }

    override func checkConfig() -> Bool {
        return applicationGroup?.userDefaults != nil
    }
    
    override func writeMessage(message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(message)
        guard let userDefaults = self.applicationGroup?.userDefaults else {
            return false
        }
        userDefaults.setObject(data, forKey: identifier)
        return true
    }
    
    override func readMessageForIdentifier(identifier: MessageIdentifier) -> Message? {
        guard let data = self.applicationGroup?.userDefaults?.objectForKey(identifier) as? NSData else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Message
    }
    
    override func deleteContentForIdentifier(identifier: MessageIdentifier) throws {
        self.applicationGroup?.userDefaults?.removeObjectForKey(identifier)
    }
    
    override func deleteContentForAllMessageIdentifiers() throws {
        if let keys = self.applicationGroup?.userDefaults?.dictionaryRepresentation().keys {
            for key in keys {
                self.applicationGroup?.userDefaults?.removeObjectForKey(key)
            }
        }
    }

    override func readMessages() -> [MessageIdentifier: Message]? {
        guard let userDefaults = self.applicationGroup?.userDefaults else {
            return nil
        }
        
        let messageLists = userDefaults.dictionaryRepresentation().filter { $0.1 is Message }
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

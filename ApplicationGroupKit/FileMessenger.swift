//
//  FileMessenger.swift
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

public class FileMessenger: Messenger {
    
    public var fileManager = NSFileManager.defaultManager()
    public var directory: String?
    
    public init(directory: String?) {
        super.init()
        self.directory = directory
    }

    public override var type: MessengerType {
        return .File(directory: directory)
    }
    
    override func checkConfig() -> Bool {
        guard let url = containerURLForSecurity() else {
            return false
        }
        do {
            try fileManager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }
        return true
    }
    
    override func writeMessage(message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        guard let path = filePathForIdentifier(identifier) else {
            return false
        }
        
        return NSKeyedArchiver.archiveRootObject(message, toFile: path)
    }
    
    override func readMessageForIdentifier(identifier: MessageIdentifier) -> Message? {
        guard let path = filePathForIdentifier(identifier) else {
            return nil
        }
        
        return messageFromFile(path)
    }


    override func deleteContentForIdentifier(identifier: MessageIdentifier) throws {
        guard let path = filePathForIdentifier(identifier) else {
            return
        }
        var isDirectory: ObjCBool = false
        if self.fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) {
            if !isDirectory {
                try self.fileManager.removeItemAtPath(path)
            }
        }
    }
    
    override func deleteContentForAllMessageIdentifiers() throws {
        guard let url = containerURLForSecurity() else {
            return
        }
        let contents = try fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: [])
        for content in contents {
            var isDirectory: ObjCBool = false
            if self.fileManager.fileExistsAtPath(content.absoluteString, isDirectory: &isDirectory) {
                if !isDirectory {
                    try self.fileManager.removeItemAtURL(content)
                }
            }
        }
    }

    override func readMessages() -> [MessageIdentifier: Message]? {
        guard let url = applicationGroup?.containerURLForSecurity(fileManager) else {
            return nil
        }
        
        guard let contents = try? fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: []) else {
            return nil
        }
        var messages = [MessageIdentifier: Message]()
        for content in contents {
            let path = content.absoluteString // XXX use absoluteString or path?
            if let messageIdenfier = content.pathComponents?.last,
                message = messageFromFile(path) {
                messages[messageIdenfier] = message
            }
        }
        return messages
    }

    // MARK: privates
    internal func containerURLForSecurity() -> NSURL? {
        let container = applicationGroup?.containerURLForSecurity(fileManager)
        guard let directory = self.directory else {
            return container
        }
        return container?.URLByAppendingPathComponent(directory)
    }
    
    internal func fileURLForIdentifier(identifier: MessageIdentifier) -> NSURL? {
       return containerURLForSecurity()?.URLByAppendingPathComponent(identifier)
    }
    
    internal func filePathForIdentifier(identifier: MessageIdentifier) -> String? {
        guard let url = fileURLForIdentifier(identifier) else {
            return nil
        }
        return url.absoluteString
    }
    
    internal func messageFromFile(path: String) -> Message? {
       return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Message
    }
    
}

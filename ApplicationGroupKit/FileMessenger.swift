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
    
    public override init() {
        super.init()
    }
    
    override func checkConfig() -> Bool {
        return applicationGroup?.containerURLForSecurity(fileManager) != nil
    }
    
    override func writeMessage(message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        guard let url = applicationGroup?.containerURLForSecurity(fileManager)?.URLByAppendingPathComponent(identifier) else {
            return false
        }
        let path = url.absoluteString
        
        return NSKeyedArchiver.archiveRootObject(message, toFile: path)
    }
    
    override func readMessageForIdentifier(identifier: MessageIdentifier) -> Message? {
        guard let path = filePathForIdentifier(identifier) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Message
    }
    
    private func filePathForIdentifier(identifier: MessageIdentifier) -> String? {
        guard let url = applicationGroup?.containerURLForSecurity(fileManager)?.URLByAppendingPathComponent(identifier) else {
            return nil
        }
        return url.absoluteString
    }
    
    
    override func deleteContentForIdentifier(identifier: MessageIdentifier) throws {
        guard let path = filePathForIdentifier(identifier) else {
            return
        }
        if self.fileManager.fileExistsAtPath(path) {
            try self.fileManager.removeItemAtPath(path)
        }
    }
    
    override func deleteContentForAllMessageIdentifiers() throws {
        guard let url = applicationGroup?.containerURLForSecurity(fileManager) else {
            return
        }
        let contents = try fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: [])
        for content in contents {
            try self.fileManager.removeItemAtURL(content)
        }
    }
    
}

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

open class FileMessenger: Messenger {

    open var fileManager = FileManager.default
    open var directory: String?

    public init(directory: String?) {
        super.init()
        self.directory = directory
    }

    open override var type: MessengerType {
        return .file(directory: directory)
    }

    override func checkConfig() -> Bool {
        guard let url = containerURLForSecurity() else {
            return false
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }
        return true
    }

    override func writeMessage(_ message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        guard let path = filePathForIdentifier(identifier) else {
            return false
        }

        return NSKeyedArchiver.archiveRootObject(message, toFile: path)
    }

    override func readMessageForIdentifier(_ identifier: MessageIdentifier) -> Message? {
        guard let path = filePathForIdentifier(identifier) else {
            return nil
        }

        return messageFromFile(path)
    }

    override func deleteContentForIdentifier(_ identifier: MessageIdentifier) throws {
        guard let path = filePathForIdentifier(identifier) else {
            return
        }
        var isDirectory: ObjCBool = false
        if self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                try self.fileManager.removeItem(atPath: path)
            }
        }
    }

    override func deleteContentForAllMessageIdentifiers() throws {
        guard let url = containerURLForSecurity() else {
            return
        }
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for content in contents {
            var isDirectory: ObjCBool = false
            if self.fileManager.fileExists(atPath: content.absoluteString, isDirectory: &isDirectory) {
                if !isDirectory.boolValue {
                    try self.fileManager.removeItem(at: content)
                }
            }
        }
    }

    override func readMessages() -> [MessageIdentifier: Message]? {
        guard let url = applicationGroup?.containerURLForSecurity(fileManager) else {
            return nil
        }

        guard let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
            return nil
        }
        var messages = [MessageIdentifier: Message]()
        for content in contents {
            let path = content.absoluteString // XXX use absoluteString or path?
            if let messageIdenfier = content.pathComponents.last,
                let message = messageFromFile(path) {
                messages[messageIdenfier] = message
            }
        }
        return messages
    }

    // MARK: privates
    internal func containerURLForSecurity() -> URL? {
        let container = applicationGroup?.containerURLForSecurity(fileManager)
        guard let directory = self.directory else {
            return container
        }
        return container?.appendingPathComponent(directory)
    }

    internal func fileURLForIdentifier(_ identifier: MessageIdentifier) -> URL? {
       return containerURLForSecurity()?.appendingPathComponent(identifier)
    }

    internal func filePathForIdentifier(_ identifier: MessageIdentifier) -> String? {
        guard let url = fileURLForIdentifier(identifier) else {
            return nil
        }
        return url.absoluteString
    }

    internal func messageFromFile(_ path: String) -> Message? {
       return NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Message
    }

}

//
//  FileCoordinatorMessenger.swift
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

open class FileCoordinatorMessenger: FileMessenger {

    let fileCoordinator: NSFileCoordinator

    public init(directory: String?, fileCoordinator: NSFileCoordinator) {
        self.fileCoordinator = fileCoordinator
        super.init(directory: directory)
    }

    open override var type: MessengerType {
        return .fileCoordinator(directory: directory, fileCoordinator: fileCoordinator)
    }

    override func writeMessage(_ message: Message, forIdentifier identifier: MessageIdentifier) -> Bool {
        guard let url = fileURLForIdentifier(identifier) else {
            return false
        }

        let data = dataFromMessage(message)

        var success = false
        var error: NSError?
        fileCoordinator.coordinate(writingItemAt: url, options: [], error: &error) { (url) -> Void in
            do {
               try data.write(to: url, options: [])
                success = true
            } catch {
                success = false
            }
        }
        if error != nil {
            return false
        }

        return success
    }

    override func readMessageForIdentifier(_ identifier: MessageIdentifier) -> Message? {
        guard let url = fileURLForIdentifier(identifier) else {
            return nil
        }

        var readData: Data? = nil
        var error: NSError?
        fileCoordinator.coordinate(readingItemAt: url, options: [], error: &error) { (url) -> Void in
            readData = try? Data(contentsOf: url)
        }
        if error != nil {
            return nil
        }
        guard let data = readData else {
            return nil
        }
        return messageFromData(data)
    }

    override func readMessages() -> [MessageIdentifier: Message]? {
        guard let url = applicationGroup?.containerURLForSecurity(fileManager) else {
            return nil
        }

        var messages = [MessageIdentifier: Message]()
        var error: NSError?
        fileCoordinator.coordinate(readingItemAt: url, options: [], error: &error) { (url) -> Void in
            guard let contents = try? self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) else {
                return
            }
            for content in contents {
                let path = content.absoluteString // XXX use absoluteString or path?
                if let messageIdenfier = content.pathComponents.last,
                    let message = self.messageFromFile(path) {
                        messages[messageIdenfier] = message
                }
            }
        }
        if error != nil {
            return nil
        }

        return messages
    }

}

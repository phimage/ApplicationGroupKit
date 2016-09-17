//
//  DarwinNotificationCenter
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

open class DarwinNotificationCenter {

    open static var defaultCenter = DarwinNotificationCenter()

    fileprivate var observers: [String: Set<Observer>] = [:]

    fileprivate init(){}
    deinit {
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            CFNotificationCenterRemoveEveryObserver(center, Unmanaged.passUnretained(self).toOpaque())
        }
    }

    open func addObserver(name: String, object: ObserverObject, usingBlock block: @escaping () -> Void){
        var handles = observers[name] ?? Set<Observer>()
        handles.insert(Observer(object: object, block: block))
        observers.updateValue(handles, forKey: name)
        
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            let callback: CFNotificationCallback =  { (center, observer, name, object, userInfo) in
                if let name = name?.rawValue as? String {
                    DarwinNotificationCenter.defaultCenter.postNotification(name: name)
                }
            }

            CFNotificationCenterAddObserver(center, Unmanaged.passUnretained(self).toOpaque(), callback, name as CFString, nil, CFNotificationSuspensionBehavior.deliverImmediately)
        }
    }

    open func postNotification(name: String){
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            CFNotificationCenterPostNotificationWithOptions(center, CFNotificationName(name as CFString), nil, nil, UInt(kCFNotificationDeliverImmediately | kCFNotificationPostToAllSessions))
        }
    }
    
    open func remove(observer: ObserverObject){
        for name in observers.keys {
            remove(observer: observer, name: name)
        }
    }

    open func remove(observer: ObserverObject, name: String){
        var handles = observers[name] ?? Set<Observer>()
        handles = Set<Observer>(handles.filter { (item) -> Bool in
            return !item.object.isEqual(observer)
        })
        if handles.isEmpty {
            observers.removeValue(forKey: name)
        } else {
            observers.updateValue(handles, forKey: name)
        }
    }

    // MARK - privates
    fileprivate func notificationWithIdentifier(_ name: String) {
        let observers = self.observers[name] ?? Set<Observer>()
        for observer in observers {
            observer.block()
        }
    }
    
}

// MARK: Observer

public typealias ObserverObject = NSObjectProtocol
private struct Observer {
    var object: ObserverObject // or Hashable (but work only with generic constraint
    var block: () -> Void
    
    init(object: ObserverObject, block: @escaping () -> Void){
        self.object = object
        self.block = block
    }
}

extension Observer: Hashable {
    var hashValue: Int {
        return object.hash
    }
}
private func == (lhs: Observer, rhs: Observer) -> Bool{
    return lhs.object.isEqual(rhs.object)
}

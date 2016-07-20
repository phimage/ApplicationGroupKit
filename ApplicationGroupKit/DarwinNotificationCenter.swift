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

let kNotificationCenter: CFString = "NotificationCenter"
public class DarwinNotificationCenter {

    public static var defaultCenter = DarwinNotificationCenter()

    private var observers: [String: Set<Observer>] = [:]

    private init(){}
    deinit {
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            CFNotificationCenterRemoveEveryObserver(center, unsafeAddressOf(self))
        }
    }

    public func addObserverForName(name: String, object: ObserverObject, usingBlock block: () -> Void){
        var handles = observers[name] ?? Set<Observer>()
        handles.insert(Observer(object: object, block: block))
        observers.updateValue(handles, forKey: name)
        
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            let callback: CFNotificationCallback =  { (center, observer, name, object, userInfo) in
                DarwinNotificationCenter.defaultCenter.notificationWithIdentifier(name as String)
            }

            CFNotificationCenterAddObserver(center, unsafeAddressOf(self), callback, name as CFString, nil, CFNotificationSuspensionBehavior.DeliverImmediately)
        }
    }

    public func postNotificationName(name: String){
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            #if swift(>=2.3)
                   CFNotificationCenterPostNotificationWithOptions(center, name as CFStringRef, nil, nil, UInt(kCFNotificationDeliverImmediately | kCFNotificationPostToAllSessions))
            #else
                CFNotificationCenterPostNotificationWithOptions(center, name as CFStringRef, UnsafePointer<Void>(), nil, UInt(kCFNotificationDeliverImmediately | kCFNotificationPostToAllSessions))
            #endif
        }
    }
    
    public func removeObserver(observer: ObserverObject){
        for name in observers.keys {
            removeObserver(observer, name: name)
        }
    }

    public func removeObserver(observer: ObserverObject, name: String){
        var handles = observers[name] ?? Set<Observer>()
        handles = Set<Observer>(handles.filter { (item) -> Bool in
            return !item.object.isEqual(observer)
        })
        if handles.isEmpty {
            observers.removeValueForKey(name)
        } else {
            observers.updateValue(handles, forKey: name)
        }
    }

    // MARK - privates
    private func notificationWithIdentifier(name: String) {
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
    
    init(object: ObserverObject, block: () -> Void){
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

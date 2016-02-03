# ApplicationGroupKit

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios_osx_tvos-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/phimage/ApplicationGroupKit.svg?style=flat
           )](https://github.com/phimage/ApplicationGroupKit/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/ApplicationGroupKit.svg?style=flat)](http://cocoadocs.org/docsets/ApplicationGroupKit/)
[![Join the chat at https://gitter.im/phimage/ApplicationGroupKit](https://img.shields.io/badge/GITTER-join%20chat-00D06F.svg)](https://gitter.im/phimage/ApplicationGroupKit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[<img align="left" src="logo.png" hspace="20">](#logo) Applications communication using group identifier.
```swift
let appGroup = ApplicationGroup(identifier: "group.id")
appGroup.postMessage("your message", withIdentifier: "key")
```
```swift
appGroup.observeMessageForIdentifier("key") { message in
 ...
}
```

## Usage

The data sharing between applications and extensions require you to enable App Group or Keychain sharing (if using key chain messenger type):
- [Configuring App Groups](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW61)
- [Configuring Keychain Sharing](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW15)

Then you must create an `ApplicationGroup` object.
```swift
let appGroup = ApplicationGroup(identifier: "your.application.group.id")!
```
You can choose the way the messages are transferred by choosing one of the `MessengerType` enum value (`File`, `UserDefaults`, `FileCoordinator`, `KeyChain`, ...)
```swift
let appGroup = ApplicationGroup(identifier: "..", messengerType: .UserDefaults)!
```
:warning: `ApplicationGroup` could return `nil` if you misconfigured application group.

### Post a message

Choose a message identifier and post any `NSCoding` compliant object
```swift
appGroup.postMessage("your message", withIdentifier: "key to identify message")
```

#### Using subscript
```swift
appGroup["key to identify message"] = "your message"
```

### Receive a message
Using the same message identifier you can receive message into callback
```swift
appGroup.observeMessageForIdentifier("key to identify message") { message in
 ..
}
```
### Read a message
You can read current value using same message identifier
```swift
if let message = appGroup.messageForIdentifier("key to identify message") {
  ..
}
```
#### Using subscript
```swift
if let message = appGroup["key to identify message"] as? String { .. }
```
## Todo
- Tests
- WatchKit (WatchConnectivity/WCSession...)
- Carthage: let me know if carthage work and I will add the shell.io badges and installation instruction

## Contribute
I am more than happy to accept external contributions to the project in the form of feedback, bug reports and even better pull requests.

Implement WatchKit features and I will add you to the project (I have no need and time to do it now)

## Installation

## Using Cocoapods ##
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'ApplicationGroupKit'
    ```

2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.

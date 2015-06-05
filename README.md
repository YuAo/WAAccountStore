# WAAccountStore
[![Build Status](https://travis-ci.org/YuAo/WAAccountStore.svg?branch=master)](https://travis-ci.org/YuAo/WAAccountStore)
![CocoaPods Platform](https://img.shields.io/cocoapods/p/WAAccountStore.svg?style=flat-square)
![CocoaPods Version](https://img.shields.io/cocoapods/v/WAAccountStore.svg?style=flat-square)
![CocoaPods License](https://img.shields.io/cocoapods/l/WAAccountStore.svg?style=flat-square)

`WAAccountStore` is a simple yet extensible account system.

It encapsulates the basic account management functions, the security storage of the account credential. And allows you to store any useful information you want with a account.

##Infrastructure

`WAAccount` represents a user account. It contains a `WAAccountCredential` for storing account credential info and a user info object for storing additional info.

`WAAccountCredential` provides a secure way of storing account credentials. It has a `securityStorage` property. Anything in the `securityStorage` will be stored safely in the keychain.

`WAAccountStore` provides a set of account management functions, such as add account, remove account, update account, etc. As well as notifications for account change (`WAAccountStoreCurrentAccountDidChangeNotification`, `WAAccountStoreCurrentAccountUpdatedNotification`)

##Usage

Use the default store throughout your app.

```swift

WAAccountStore.defaultStore()

```

You may start using `WAAccountStore` directly. However creating some simple extensions for `WAAccountCredential` and `WAAccount` will make your life easier.

For example:

__Associate your user model with `WAAccount`.__

```swift
//Assuming `User` is your user model class.
extension WAAccount {
    var user: User {
        get {
            return self.userInfo as! User
        }
    }
    
    convenience init(identifier: String, credential: WAAccountCredential, user: User) {
        self.init(identifier: identifier, credential: credential, userInfo: user)
    }
}
```

__Direct access to `securityStorage` of `WAAccountCredential` is inconvenient. Create a extension for convenient access.__

```swift

let UserAccessTokenStorageKey = "AccessToken"

extension WAAccountCredential {
    var accessToken: String {
        get {
            return self.securityStorage[UserAccessTokenStorageKey] as! String
        }
    }
    
    convenience init(identifier: String, accessToken: String) {
        self.init(identifier: identifier, securityStorage: [UserAccessTokenStorageKey: accessToken])
    }
}

```

##Demo

There's a simple demo project in WAAccountStoreDemo folder. A `pod install` is required to open and build `WAAccountStoreDemo.xcworkspace`

##Install

Either clone the repo and manually add the files in `WAAccountStore` directory

or if you use Cocoapods, add the following to your Podfile

	pod 'WAAccountStore'


##Note

`WAAccountStore` makes use of [`WAKeyValuePersistenceStore`](https://github.com/YuAo/WAKeyValuePersistenceStore) and [`UICKeyChainStore`](https://github.com/kishikawakatsumi/UICKeyChainStore)

##Requirements

* Automatic Reference Counting (ARC)
* iOS 7.0+
* Xcode 6.3+

# WAAccountStore

`WAAccountStore` is a simple yet extensible account system.



It encapsules the basic account management functions, the security storage of the account credential. And allows you to store any useful information you want with a account.

##Infrastructure

`WAAccount` represents a user account. It contains a `WAAccountCredential` for storing account credential info and a user info object for storing additional user info.

`WAAccountCredential` provides a security way of storing account credentials. It has a `securityStorage` property. Andthing in the `securityStorage` will be stored safely in the keychain.

`WAAccountStore` provides a set of account management functions, such as add account, remove account, update account, etc. As well as notifications for account change (`WAAccountStoreCurrentAccountDidChangeNotification`, `WAAccountStoreCurrentAccountUpdatedNotification`)

##Usage

Use the default store throughout your app.

```swift

WAAccountStore.defaultStore()

```

You may start using `WAAccountStore` directly. However creating some simple extensions for `WAAccountCredential` and `WAAccount` will make your life easier.

For example:

__You may want to associate your user model with `WAAccount`.__

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

__Directly accessing `securityStorage` of `WAAccountCredential` is inconvenient.__

Create a extension for convenient access:

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

##Note

`WAAccountStore` makes use of [`WAKeyValuePersistenceStore`](https://github.com/YuAo/WAKeyValuePersistenceStore) and [`UICKeyChainStore`](https://github.com/kishikawakatsumi/UICKeyChainStore)
//
//  WAAccountStore.m
//  Wanted
//
//  Created by YuAo on 4/12/15.
//  Copyright (c) 2015 Want. All rights reserved.
//

#import "WAAccountStore.h"
#import <WAKeyValuePersistenceStore/WAKeyValuePersistenceStore.h>

NSString * const WALogoutAccount = @"WALogoutAccount";

NSString * const WALoginAccount = @"WALoginAccount";

NSString * const WAAccountStoreCurrentAccountDidChangeNotification = @"WAAccountStoreCurrentAccountDidChangeNotification";

NSString * const WAAccountStoreCurrentAccountUpdatedNotification = @"WAAccountStoreCurrentAccountUpdatedNotification";

NSString * const WAAccountStoreAccountsKey = @"WAAccountStoreAccounts";

@interface WAAccountStore ()

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) WAKeyValuePersistenceStore *internalStorage;

@property (nonatomic,copy) NSArray *cachedAccounts;

@property (nonatomic, copy) WAAccount *loginAccount;

@property (nonatomic, copy) WAAccount *logoutAccount;

@end

@implementation WAAccountStore

@synthesize cachedAccounts = _cachedAccounts;

+ (instancetype)defaultStore {
    static WAAccountStore *_defaultStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultStore = [[WAAccountStore alloc] initWithName:@"Default"];
    });
    return _defaultStore;
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
        WAKeyValuePersistenceStore *storage = [[WAKeyValuePersistenceStore alloc] initWithDirectory:NSApplicationSupportDirectory name:[@"WAAccountStore-" stringByAppendingString:self.name] objectSerializer:[WAPersistenceObjectSerializer keyedArchiveSerializer]];
        self.internalStorage = storage;
        [self reloadAccounts];
    }
    return self;
}

- (NSArray<WAAccount *> *)accounts {
    if (self.cachedAccounts) {
        return self.cachedAccounts;
    } else {
        return @[];
    }
}

- (NSArray *)storedAccounts {
    return [(id)self.internalStorage[WAAccountStoreAccountsKey] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"credential.isValid == YES"]];
}

- (NSArray *)cachedAccounts {
    if (!_cachedAccounts) {
        _cachedAccounts = self.storedAccounts;
    }
    return _cachedAccounts;
}

- (void)setCachedAccounts:(NSArray *)cachedAccounts {
    _cachedAccounts = cachedAccounts;
    [self synchronize];
}

- (void)synchronize {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (self.loginAccount) [userInfo setObject:self.loginAccount forKey:WALoginAccount];
    if (self.logoutAccount) [userInfo setObject:self.logoutAccount forKey:WALogoutAccount];
    
    NSArray *oldAccounts = self.storedAccounts;
    WAAccount *oldCurrentAccount = oldAccounts.firstObject;
    self.internalStorage[WAAccountStoreAccountsKey] = self.cachedAccounts;
    if (oldCurrentAccount) {
        if (![oldCurrentAccount.identifier isEqualToString:self.currentAccount.identifier]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WAAccountStoreCurrentAccountDidChangeNotification object:self userInfo:userInfo];
        }
    } else if (self.currentAccount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WAAccountStoreCurrentAccountDidChangeNotification object:self userInfo:userInfo];
    }
    
    [self cleanTempAccount];
}

- (void)cleanTempAccount {
    self.loginAccount = nil;
    self.logoutAccount = nil;
}

- (WAAccount *)currentAccount {
    return self.cachedAccounts.firstObject;
}

- (void)setCurrentAccount:(WAAccount *)currentAccount {
    NSParameterAssert(currentAccount);
    [self addAccount:currentAccount];
}

- (void)addAccount:(WAAccount *)account {
    NSParameterAssert(account);
    
    self.loginAccount = account;
    self.logoutAccount = [self.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@",account.identifier]].firstObject;
    
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[self.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier != %@",account.identifier]]];
    [accounts insertObject:account atIndex:0];
    self.cachedAccounts = accounts;
}

- (void)reloadAccounts {
    _cachedAccounts = nil;
    [self cachedAccounts];
}

- (void)removeAccountWithIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);

    NSArray *accounts = [self.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier != %@",identifier]];
    
    self.loginAccount = accounts.firstObject;
    self.logoutAccount = [self.accounts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]].firstObject;
    
    self.cachedAccounts = accounts;
}

- (void)updateAccount:(WAAccount *)newAccount {
    NSParameterAssert(newAccount);
    
    self.loginAccount = newAccount;
    self.logoutAccount = nil;
    
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:self.cachedAccounts];
    NSUInteger index = [accounts indexOfObjectPassingTest:^BOOL(WAAccount *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:newAccount.identifier]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound) {
        accounts[index] = newAccount;
    }
    self.cachedAccounts = accounts;
    
    if (index == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WAAccountStoreCurrentAccountUpdatedNotification object:self];
    }
}

@end

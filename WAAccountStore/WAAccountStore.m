//
//  WAAccountStore.m
//  Wanted
//
//  Created by YuAo on 4/12/15.
//  Copyright (c) 2015 Want. All rights reserved.
//

#import "WAAccountStore.h"
#import <WAKeyValuePersistenceStore/WAKeyValuePersistenceStore.h>

NSString * const WAAccountStoreCurrentAccountDidChangeNotification = @"WAAccountStoreCurrentAccountDidChangeNotification";

NSString * const WAAccountStoreCurrentAccountUpdatedNotification = @"WAAccountStoreCurrentAccountUpdatedNotification";

NSString * const WAAccountStoreAccountsKey = @"WAAccountStoreAccounts";

@interface WAAccountStore ()

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) WAKeyValuePersistenceStore *internalStorage;

@property (nonatomic,copy) NSArray *cachedAccounts;

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

- (NSArray *)accounts {
    return self.cachedAccounts;
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
    NSArray *oldAccounts = self.storedAccounts;
    WAAccount *oldCurrentAccount = oldAccounts.firstObject;
    self.internalStorage[WAAccountStoreAccountsKey] = self.cachedAccounts;
    if (oldCurrentAccount) {
        if (![oldCurrentAccount.identifier isEqualToString:self.currentAccount.identifier]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WAAccountStoreCurrentAccountDidChangeNotification object:self];
        }
    } else if (self.currentAccount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WAAccountStoreCurrentAccountDidChangeNotification object:self];
    }
}

- (WAAccount *)currentAccount {
    return [self.cachedAccounts.firstObject copy];
}

- (void)setCurrentAccount:(WAAccount *)currentAccount {
    NSParameterAssert(currentAccount);
    [self addAccount:currentAccount.copy];
}

- (void)addAccount:(WAAccount *)account {
    NSParameterAssert(account);
    [self removeAccountWithIdentifier:account.identifier];
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:self.cachedAccounts];
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
    self.cachedAccounts = accounts;
}

- (void)updateAccount:(WAAccount *)newAccount {
    NSParameterAssert(newAccount);
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

//
//  WAAccountStore.h
//  Wanted
//
//  Created by YuAo on 4/12/15.
//  Copyright (c) 2015 Want. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WAAccountStore/WAAccount.h>
#import <WAAccountStore/WAAccountCredential.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const WAAccountStoreCurrentAccountDidChangeNotification;

extern NSString * const WAAccountStoreCurrentAccountUpdatedNotification;

@interface WAAccountStore : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name;

+ (instancetype)defaultStore;

@property (nonatomic,copy,readonly,nullable) NSArray *accounts;

@property (nonatomic,copy,nullable) WAAccount *currentAccount;

- (void)addAccount:(WAAccount *)account;

- (void)removeAccountWithIdentifier:(NSString *)identifier;

- (void)updateAccount:(WAAccount *)newAccount;

- (void)reloadAccounts;

@end

NS_ASSUME_NONNULL_END

//
//  WAAccount.h
//  Wanted
//
//  Created by YuAo on 4/12/15.
//  Copyright (c) 2015 Want. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WAAccountCredential;

typedef id<NSObject, NSCoding, NSCopying> WAAccountUserInfo;

@interface WAAccount : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic,copy,readonly) NSString *identifier;

@property (nonatomic,copy,readonly) WAAccountCredential *credential;

@property (nonatomic,copy,readonly,nullable) WAAccountUserInfo userInfo;

- (instancetype)initWithIdentifier:(NSString *)identifier
                        credential:(WAAccountCredential *)credential
                          userInfo:(nullable WAAccountUserInfo)userInfo NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
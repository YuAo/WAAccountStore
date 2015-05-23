//
//  WAAccount.m
//  Wanted
//
//  Created by YuAo on 4/12/15.
//  Copyright (c) 2015 Want. All rights reserved.
//

#import "WAAccount.h"
#import "WAAccountCredential.h"

@interface WAAccount ()

@property (nonatomic,copy) NSString *identifier;

@property (nonatomic,copy) WAAccountCredential *credential;

@property (nonatomic,copy) WAAccountUserInfo userInfo;

@end

@implementation WAAccount

- (instancetype)initWithIdentifier:(NSString *)identifier
                        credential:(WAAccountCredential *)credential
                          userInfo:(WAAccountUserInfo)userInfo
{
    if (self = [super init]) {
        NSParameterAssert(identifier);
        NSParameterAssert(credential);
        self.identifier = identifier;
        self.credential = credential;
        self.userInfo = userInfo;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.credential forKey:NSStringFromSelector(@selector(credential))];
    if (self.userInfo != nil) {
        [aCoder encodeObject:self.userInfo forKey:NSStringFromSelector(@selector(userInfo))];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *identifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(identifier))];
    WAAccountCredential *credential = [aDecoder decodeObjectOfClass:[WAAccountCredential class] forKey:NSStringFromSelector(@selector(credential))];
    if (identifier && credential) {
        return [self initWithIdentifier:identifier
                             credential:credential
                               userInfo:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userInfo))]];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    WAAccount *account = [[WAAccount allocWithZone:zone] initWithIdentifier:self.identifier
                                                                 credential:self.credential
                                                                   userInfo:self.userInfo];
    return account;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
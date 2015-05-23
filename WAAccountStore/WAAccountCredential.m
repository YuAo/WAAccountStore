//
//  WAAccountCredential.m
//  Pods
//
//  Created by YuAo on 4/12/15.
//
//

#import "WAAccountCredential.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

static NSString * WAAccountCredentialKeyChainStoreName() {
    static NSString *_WAAccountCredentialKeyChainStoreName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _WAAccountCredentialKeyChainStoreName = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@"-WAAccountCredential"];
    });
    return _WAAccountCredentialKeyChainStoreName;
}

@interface WAAccountCredential ()

@property (nonatomic,copy) NSString *identifier;

@property (nonatomic,copy) NSDictionary *securityStorage;

@property (nonatomic,readonly) NSString *keychainKeyForSecurityStorage;

@end

@implementation WAAccountCredential

+ (UICKeyChainStore *)keyChainStore {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:WAAccountCredentialKeyChainStoreName()];
    keychain.accessibility = UICKeyChainStoreAccessibilityAlways;
    return keychain;
}

- (instancetype)initWithIdentifier:(NSString *)identifier securityStorage:(NSDictionary *)securityStorage {
    if (self = [super init]) {
        NSParameterAssert(identifier);
        NSParameterAssert(securityStorage);
        self.identifier = identifier;
        self.securityStorage = securityStorage;
    }
    return self;
}

+ (NSString *)keychainKeyForSecurityStorageWithCredentialIdentifier:(NSString *)identifier {
    return [identifier stringByAppendingString:NSStringFromSelector(@selector(securityStorage))];
}

- (NSString *)keychainKeyForSecurityStorage {
    return [WAAccountCredential keychainKeyForSecurityStorageWithCredentialIdentifier:self.identifier];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.isValid) {
        [coder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
        [WAAccountCredential.keyChainStore setData:[NSKeyedArchiver archivedDataWithRootObject:self.securityStorage] forKey:self.keychainKeyForSecurityStorage];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *identifier = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(identifier))];
    if (identifier) {
        NSError *error;
        NSData *securityStorageData = [WAAccountCredential.keyChainStore dataForKey:[WAAccountCredential keychainKeyForSecurityStorageWithCredentialIdentifier:identifier] error:&error];
        if (securityStorageData && !error) {
            NSDictionary *securityStorage = [NSKeyedUnarchiver unarchiveObjectWithData:securityStorageData];
            if ([securityStorage isKindOfClass:[NSDictionary class]]) {
                return [self initWithIdentifier:identifier securityStorage:securityStorage];
            }
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    WAAccountCredential *credential = [[WAAccountCredential allocWithZone:zone] initWithIdentifier:self.identifier
                                                                                   securityStorage:self.securityStorage];
    return credential;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isValid {
    if (self.identifier.length > 0 && self.securityStorage.allKeys.count > 0) {
        return YES;
    }
    return NO;
}

@end
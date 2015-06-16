//
//  WAAccountCredential.h
//  Pods
//
//  Created by YuAo on 4/12/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WAAccountCredential : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic,copy,readonly) NSString *identifier;

@property (nonatomic,copy,readonly) NSDictionary *securityStorage;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIdentifier:(NSString *)identifier
                   securityStorage:(NSDictionary *)securityStorage NS_DESIGNATED_INITIALIZER;

@property (nonatomic,readonly) BOOL isValid;

@end

NS_ASSUME_NONNULL_END
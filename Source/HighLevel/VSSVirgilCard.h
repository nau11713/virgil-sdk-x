//
//  VSSVirgilCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSModelCommons.h"

#import "VSSCreateCardRequest.h"
#import "VSSRevokeCardRequest.h"

@interface VSSVirgilCard : NSObject

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString * __nullable identifier;
@property (nonatomic, readonly) NSString * __nonnull identity;
@property (nonatomic, readonly) NSString * __nonnull identityType;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable customFields;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable info;
@property (nonatomic, readonly) VSSCardScope scope;
@property (nonatomic, readonly) BOOL isPublished;

- (NSData * __nonnull)encryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr;

//public string Export()

@end
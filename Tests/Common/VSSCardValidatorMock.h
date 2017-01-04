//
//  VSSCardValidatorMock.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/4/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

@import VirgilSDK;

@interface VSSCardValidatorMock : VSSCardValidator

- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nonnull)crypto cardId:(NSString * __nonnull)cardId publicKey:(VSSPublicKey * __nonnull)publicKey;

- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nonnull)crypto NS_UNAVAILABLE;

@end

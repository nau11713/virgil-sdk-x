//
//  VSSCardValidatorMock.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/4/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardValidatorMock.h"

@interface VSSCardValidatorMock ()

@property (nonatomic) NSString *cardId;
@property (nonatomic) VSSPublicKey *publicKey;

@end

@implementation VSSCardValidatorMock

- (id)copyWithZone:(NSZone *)zone {
    id<VSSCrypto> crypto = [self performSelector:@selector(crypto)];
    VSSCardValidatorMock *copy = [[VSSCardValidatorMock alloc] initWithCrypto:crypto cardId:self.cardId publicKey:self.publicKey];
    NSMutableDictionary<NSString *, VSSPublicKey *> *copyVerifiers = [copy performSelector:@selector(verifiers)];
    [copyVerifiers removeAllObjects];
    
    for (NSString *cardId in self.verifiers) {
        copyVerifiers[cardId] = self.verifiers[cardId];
    }
    
    return copy;
}

- (instancetype)initWithCrypto:(id<VSSCrypto>)crypto cardId:(NSString * __nonnull)cardId publicKey:(VSSPublicKey * __nonnull)publicKey {
    self = [super initWithCrypto:crypto];
    if (self) {
        _cardId = [cardId copy];
        _publicKey = [publicKey copy];
        NSMutableDictionary<NSString *, VSSPublicKey *> *verifiers = (NSMutableDictionary<NSString *, VSSPublicKey *> *)self.verifiers;
        [verifiers removeObjectForKey:@"3e29d43373348cfb373b7eae189214dc01d7237765e572db685839b64adca853"];
        verifiers[cardId] = publicKey;
    }
    
    return self;
}

@end

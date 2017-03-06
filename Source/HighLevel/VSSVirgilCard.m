//
//  VSSVirgilCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCardPrivate.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSVirgilApi.h"
#import "VSSRequestSigner.h"

@implementation VSSVirgilCard

- (instancetype)initWithContext:(VSSVirgilApiContext *)context request:(VSSCreateCardRequest *)request {
    self = [super init];
    if (self) {
        _context = context;
        _request = request;
    }
    
    return self;
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context card:(VSSCard *)card {
    self = [super init];
    if (self) {
        _context = context;
        _card = card;
    }
    
    return self;
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context data:(NSString *)data {
    VSSCard *card = [[VSSCard alloc] initWithData:data];
    
    if (card != nil) {
        return [self initWithContext:context card:card];
    }
    
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithData:data];
    if (request != nil) {
        return [self initWithContext:context request:request];
    }
    
    return nil;
}

- (BOOL)isPublished {
    return self.card != nil;
}

- (NSData *)encryptData:(NSData *)data error:(NSError **)errorPtr {
    VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:self.publicKey];
    
    return [self.context.crypto encryptData:data forRecipients:@[publicKey] error:errorPtr];
}

- (BOOL)verifyData:(NSData *)data withSignature:(NSData *)signature error:(NSError **)errorPtr {
    VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:self.publicKey];
    
    return [self.context.crypto verifyData:data withSignature:signature usingSignerPublicKey:publicKey error:errorPtr];
}

- (void)publishWithCompletion:(void (^)(NSError *))callback {
    if (self.isPublished) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"This card is already published" }]);
        return;
    }
    
    switch (self.scope) {
        case VSSCardScopeGlobal: break;
        case VSSCardScopeApplication: {
            if (self.context.credentials == nil) {
                callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To create Application card you need to provide Credentials to VirgilApiContext" }]);
                return;
            }
            NSString *appId = self.context.credentials.appId;
            VSSPrivateKey *appKey = self.context.credentials.appKey;
            VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.context.crypto];
            NSError *error;
            [signer authoritySignRequest:self.request forAppId:appId withPrivateKey:appKey error:&error];
            if (error != nil) {
                callback(error);
                return;
            }
                
            break;
        }
    }
    
    [self.context.client createCardWithRequest:self.request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            callback(error);
            return;
        }
        
        self.card = card;
        callback(nil);
    }];
}

- (NSString *)identifier {
    if (self.card != nil)
        return self.card.identifier;
    
    return nil;
}

- (NSString *)identity {
    if (self.card != nil)
        return self.card.identity;
    else
        return self.request.snapshotModel.identity;
}

- (NSString *)identityType {
    if (self.card != nil)
        return self.card.identityType;
    else
        return self.request.snapshotModel.identityType;
}

- (NSData *)publicKey {
    if (self.card != nil)
        return self.card.publicKeyData;
    else
        return self.request.snapshotModel.publicKeyData;
}

- (NSDictionary<NSString *, NSString *> *)customFields {
    if (self.card != nil)
        return self.card.data;
    else
        return self.request.snapshotModel.data;
}

- (NSDictionary<NSString *, NSString *> *)info {
    if (self.card != nil)
        return self.card.info;
    else
        return self.request.snapshotModel.info;
}

- (VSSCardScope)scope {
    if (self.card != nil)
        return self.card.scope;
    else
        return self.request.snapshotModel.scope;
}

@end
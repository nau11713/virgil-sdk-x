//
//  VSS008_ClientUnitTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/4/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <URLMock/URLMock.h>

#import "VSSTestsUtils.h"
#import "VSSCardValidatorMock.h"

/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 8.;

@interface VSS008_ClientUnitTests : XCTestCase

@property (nonatomic) VSSClient *client;
@property (nonatomic) VSSCrypto *crypto;
@property (nonatomic) VSSTestsUtils *utils;
@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSSKeyPair *serviceKeys;

@end

@implementation VSS008_ClientUnitTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    [UMKMockURLProtocol enable];
    
    self.consts = [[VSSTestsConst alloc] init];
    
    VSSServiceConfig *config = [VSSServiceConfig serviceConfigWithToken:self.consts.applicationToken];
    self.crypto = [[VSSCrypto alloc] init];
    
    self.serviceKeys = [self.crypto generateKeyPair];
    
    VSSCardValidatorMock *validator = [[VSSCardValidatorMock alloc] initWithCrypto:self.crypto cardId:@"serviceCardId" publicKey:self.serviceKeys.publicKey];
    XCTAssert([validator addVerifierWithId:self.consts.applicationId publicKeyData:[[NSData alloc] initWithBase64EncodedString:self.consts.applicationPublicKeyBase64 options:0]]);
    
    config.cardValidator = validator;
    
    self.client = [[VSSClient alloc] initWithServiceConfig:config];
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    
    NSOperationQueue *queue = [self.client valueForKey:@"queue"];
    NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    urlConfig.protocolClasses = @[UMKMockURLProtocol.class];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig delegate:nil delegateQueue:queue];
    
    [self.client setValue:urlSession forKey:@"urlSession"];
}

- (void)testC04_GetCard {
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:request.snapshot];
    NSData *signature = [self.crypto generateSignatureForData:fingerprint.value withPrivateKey:self.serviceKeys.privateKey error:nil];
    
    NSString *cardId = fingerprint.hexValue;
    
    [request addSignature:signature forFingerprint:@"serviceCardId"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSDictionary *requestDict = [request performSelector:@selector(serialize)];
#pragma clang diagnostic pop
    
    NSMutableDictionary *responseDict = [requestDict mutableCopy];
    
    responseDict[@"id"] = cardId;
    responseDict[@"meta"][@"created_at"] = @"2015-12-22T07:03:42+0000";
    responseDict[@"meta"][@"card_version"] = @"4.0";
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://cards-ro.virgilsecurity.com/v4/card/%@", cardId];
    NSURL *URL = [NSURL URLWithString:urlString];
    UMKMockHTTPRequest *mockRequest = [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:URL responseStatusCode:0 responseJSON:nil];
    UMKMockHTTPResponder *mockResponder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
    mockResponder.body = jsonData;
    mockRequest.responder = mockResponder;
    
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Get card request should return 1 card which is equal to created card."];
    
    NSUInteger numberOfRequests = 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime;
    
    [self.client getCardWithId:cardId completion:^(VSSCard *foundCard, NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
        
        XCTAssert(foundCard != nil);
//        XCTAssert([self.utils checkCard:foundCard isEqualToCard:card]);
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil)
            XCTFail(@"Expectation failed: %@", error);
    }];
}

- (void)tearDown {
    [super tearDown];
}


@end

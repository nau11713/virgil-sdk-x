//
//  VSSSerializable.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSSSerializable <NSObject>

@required
- (NSDictionary * __nonnull)serialize;
+ (instancetype __nonnull)deserializeFrom:(NSDictionary * __nonnull)candidate;

@end
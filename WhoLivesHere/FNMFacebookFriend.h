//
//  FNMFacebookFriend.h
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/25/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface FNMFacebookFriend : NSObject

- (id) initWithResponseDictionary:(NSDictionary *)dict;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSURL *fbURL;
@property(nonatomic, readonly) NSString *location;
@property(nonatomic, readonly) CLLocation *locationCoordinate;

@end

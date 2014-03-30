//
//  FNMFriendClient.h
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/23/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNMFriendClient : NSObject

+ (instancetype) sharedInstance;

- (void)requestAuthorization:(void (^)(NSError *))callback;

- (void)searchForFriends:(NSString *)query
            withCallback:(void (^)(NSArray *results, NSError *error))callback;

@end

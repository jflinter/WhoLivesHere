//
//  FNMFacebookOperation.m
//  WhoLivesHere
//
//  Created by Jack Flintermann on 3/30/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMFacebookOperation.h"
#import "FNMFacebookFriend.h"
#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

static NSString *const kFriendsKey = @"friends";
static NSString *const kErrorKey = @"error";

@implementation FNMFacebookOperation

+ (FNMFacebookOperation *)allFriendsOperation {
    return [FNMFacebookOperation operationWithBlock:^(RNCompletionBlock completion) {
        NSString *fqlQuery = @"SELECT name, uid, current_location, mutual_friend_count FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) AND current_location ORDER BY name ASC";
        
        NSDictionary *queryParam = @{ @"q": fqlQuery };
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                                  if (error) {
                                      completion(@{kErrorKey: error});
                                      return;
                                  }
                                  NSArray *dicts = [result objectForKey:@"data"];
                                  NSMutableArray *friends = [@[] mutableCopy];
                                  BOOL anyNilMutualFriends = NO;
                                  for (NSDictionary *dict in dicts) {
                                      FNMFacebookFriend *friend = [[FNMFacebookFriend alloc] initWithResponseDictionary:dict];
                                      [friends addObject:friend];
                                      if (!friend.mutualFriendCount) {
                                          anyNilMutualFriends = YES;
                                      }
                                  }
                                  if (anyNilMutualFriends) {
                                      for (FNMFacebookFriend *friend in friends) {
                                          friend.mutualFriendCount = nil;
                                      }
                                  }
                                  completion(@{kFriendsKey: friends});
                              }];

    }];
}

- (NSArray *)friends {
    return [self.userInfo objectForKey:kFriendsKey];
}

- (NSArray *)error {
    return [self.userInfo objectForKey:kErrorKey];
}

@end

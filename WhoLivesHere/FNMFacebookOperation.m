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
    FNMFacebookOperation *operation;
    operation = [FNMFacebookOperation operationWithBlock:^(RNCompletionBlock completion) {
        NSString *fqlQuery = @"SELECT name, uid, pic_square, current_location FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) AND current_location ORDER BY name ASC";
        
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
                                  for (NSDictionary *dict in dicts) {
                                      FNMFacebookFriend *friend = [[FNMFacebookFriend alloc] initWithResponseDictionary:dict];
                                      [friends addObject:friend];
                                  }
                                  completion(@{kFriendsKey: friends});
                              }];

    }];
    return operation;
}

- (NSArray *)friends {
    return [self.userInfo objectForKey:kFriendsKey];
}

- (NSArray *)error {
    return [self.userInfo objectForKey:kErrorKey];
}

@end

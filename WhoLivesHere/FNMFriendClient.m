//
//  FNMFriendClient.m
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/23/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMFriendClient.h"
#import "FNMFacebookFriend.h"
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

#import "FNMFacebookOperation.h"
#import "FNMLocationOperation.h"
#import <RNConcurrentBlockOperation/RNConcurrentBlockOperation.h>

@implementation FNMFriendClient

+ (instancetype) sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)requestAuthorization:(void (^)(NSError *))callback {
    // Open a session showing the user the login UI
    NSArray *permissions = @[@"basic_info", @"friends_location", @"user_friends"];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         callback(error);
     }];
}

- (void)searchForFriends:(NSString *)query
            withCallback:(void (^)(NSArray *results, NSError *error))callback {
    FNMFacebookOperation *facebookOperation = [FNMFacebookOperation allFriendsOperation];
    FNMLocationOperation *locationOperation = [FNMLocationOperation locationOperationWithQuery:query];
    RNConcurrentBlockOperation *filteringOperation = [RNConcurrentBlockOperation operationWithBlock:^(RNCompletionBlock completion) {
        if (facebookOperation.error) {
            callback(nil, facebookOperation.error);
            return;
        }
        if (locationOperation.error) {
            callback(nil, locationOperation.error);
            return;
        }
        CLPlacemark *placemark = [locationOperation.placemarks firstObject];
        NSArray *results = [facebookOperation.friends filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FNMFacebookFriend *friend, NSDictionary *bindings) {
            CLLocationDistance distance = [friend.locationCoordinate distanceFromLocation:placemark.location];
            CLCircularRegion *region = (CLCircularRegion *)placemark.region;
            CLLocationDistance threshold = MAX(50000, region.radius);
            BOOL stringIsSubset = [query.lowercaseString rangeOfString:friend.location.lowercaseString].location != NSNotFound;
            return (distance < threshold) || stringIsSubset;
        }]];
        callback(results, nil);
        completion(@{});
    }];
    
    [filteringOperation addDependency:facebookOperation];
    [filteringOperation addDependency:locationOperation];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:facebookOperation];
    [operationQueue addOperation:locationOperation];
    [operationQueue addOperation:filteringOperation];
}

@end

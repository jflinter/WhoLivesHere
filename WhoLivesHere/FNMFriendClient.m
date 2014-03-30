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
    [self findAllFriendsWithCallback:^(NSArray *results, NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:query completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                callback(nil, error);
                return;
            }
            [[FNMFriendClient sharedInstance] findAllFriendsWithCallback:^(NSArray *results, NSError *error) {
                if (error) {
                    callback(nil, error);
                    return;
                }
                CLPlacemark *placemark = [placemarks firstObject];
                results = [results filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FNMFacebookFriend *friend, NSDictionary *bindings) {
                    CLLocationDistance distance = [friend.locationCoordinate distanceFromLocation:placemark.location];
                    CLCircularRegion *region = (CLCircularRegion *)placemark.region;
                    CLLocationDistance threshold = MAX(50000, region.radius);
                    BOOL stringIsSubset = [query.lowercaseString rangeOfString:friend.location.lowercaseString].location != NSNotFound;
                    return (distance < threshold) || stringIsSubset;
                }]];
                callback(results, nil);
            }];
        }];
    }];
}

- (void)findAllFriendsWithCallback:(void (^)(NSArray *results, NSError *error))callback {
    NSString *fqlQuery = @"SELECT name, uid, pic_square, current_location FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1=me()) AND current_location ORDER BY name ASC";

    NSDictionary *queryParam = @{ @"q": fqlQuery };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                  id result,
                                  NSError *error) {
                              if (error) {
                                  callback(nil, error);
                                  return;
                              }
                              NSArray *dicts = [result objectForKey:@"data"];
                              NSMutableArray *friends = [@[] mutableCopy];
                              for (NSDictionary *dict in dicts) {
                                  FNMFacebookFriend *friend = [[FNMFacebookFriend alloc] initWithResponseDictionary:dict];
                                  [friends addObject:friend];
                              }
                              callback(friends, nil);
                          }];
}

@end

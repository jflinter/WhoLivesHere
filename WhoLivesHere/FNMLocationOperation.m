//
//  FNMLocationOperation.m
//  WhoLivesHere
//
//  Created by Jack Flintermann on 3/30/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMLocationOperation.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const kPlacemarksKey = @"placemarks";
static NSString *const kErrorKey = @"error";

@interface FNMLocationOperation()
@property(nonatomic, readwrite) NSArray *placemarks;
@property(nonatomic, readwrite) NSError *error;
@end

@implementation FNMLocationOperation

+ (FNMLocationOperation *)locationOperationWithQuery:(NSString *)query {
    return [FNMLocationOperation operationWithBlock:^(RNCompletionBlock completion) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:query completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                completion(@{kErrorKey: error});
                return;
            }
            completion(@{kPlacemarksKey: placemarks});
            return;
        }];
    }];
}

- (NSError *)error {
    return [self.userInfo objectForKey:kErrorKey];
}

- (NSArray *)placemarks {
    return [self.userInfo objectForKey:kPlacemarksKey];
}

@end

//
//  FNMFacebookFriend.m
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/25/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMFacebookFriend.h"
#import <CoreLocation/CoreLocation.h>

@implementation FNMFacebookFriend

- (id) initWithResponseDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = [dict objectForKey:@"name"];
        _fbURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", [dict objectForKey:@"uid"]]];
        _location = [[dict objectForKey:@"current_location"] objectForKey:@"name"];
        CLLocationDegrees lat = [[[dict objectForKey:@"current_location"] objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees lng = [[[dict objectForKey:@"current_location"] objectForKey:@"longitude"] doubleValue];
        _locationCoordinate = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"FNMFacebookFriend. Name: %@ Location: %@", self.name, self.location];
}

@end

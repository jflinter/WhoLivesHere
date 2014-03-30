//
//  FNMFacebookOperation.h
//  WhoLivesHere
//
//  Created by Jack Flintermann on 3/30/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RNConcurrentBlockOperation/RNConcurrentBlockOperation.h>

@interface FNMFacebookOperation : RNConcurrentBlockOperation
@property(nonatomic, readonly) NSArray *friends;
@property(nonatomic, readonly) NSError *error;

+ (FNMFacebookOperation *)allFriendsOperation;
@end

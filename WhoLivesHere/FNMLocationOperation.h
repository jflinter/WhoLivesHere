//
//  FNMLocationOperation.h
//  WhoLivesHere
//
//  Created by Jack Flintermann on 3/30/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "RNConcurrentBlockOperation.h"

@interface FNMLocationOperation : RNConcurrentBlockOperation
@property(nonatomic, readonly) NSArray *placemarks;
@property(nonatomic, readonly) NSError *error;

+ (FNMLocationOperation *)locationOperationWithQuery:(NSString *)query;
@end

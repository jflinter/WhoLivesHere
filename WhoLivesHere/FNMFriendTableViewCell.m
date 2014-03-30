//
//  FNMFriendTableViewCell.m
//  WhoLivesHere
//
//  Created by Jack Flintermann on 3/30/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMFriendTableViewCell.h"
#import "FNMFacebookFriend.h"

@implementation FNMFriendTableViewCell

- (void) configureWithFriend:(FNMFacebookFriend *)facebookFriend {
    self.nameLabel.text = facebookFriend.name;
    self.locationLabel.text = facebookFriend.location;
    NSString *message;
    if (facebookFriend.mutualFriendCount == 1) {
        message = NSLocalizedString(@"%i Mutual Friend", nil);
    }
    else {
        message = NSLocalizedString(@"%i Mutual Friends", nil);
    }
    self.mutualFriendLabel.text = [NSString stringWithFormat:message, facebookFriend.mutualFriendCount];
}

@end

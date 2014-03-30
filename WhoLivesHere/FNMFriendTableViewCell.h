//
//  FNMFriendTableViewCell.h
//  WhoLivesHere
//
//  Created by Jack Flintermann on 3/30/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNMFacebookFriend;

@interface FNMFriendTableViewCell : UITableViewCell
@property(nonatomic, weak, readwrite) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *locationLabel;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *mutualFriendLabel;
- (void) configureWithFriend:(FNMFacebookFriend *)facebookFriend;
@end

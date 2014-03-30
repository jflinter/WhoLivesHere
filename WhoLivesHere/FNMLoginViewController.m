//
//  FNMLoginViewController.m
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/23/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMLoginViewController.h"
#import "FNMFriendClient.h"

@implementation FNMLoginViewController

- (IBAction)connectToFacebook:(id)sender {
    [[FNMFriendClient sharedInstance] requestAuthorization:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Womp womp", nil) message:NSLocalizedString(@"Something went wrong.", nil) delegate:Nil cancelButtonTitle:NSLocalizedString(@"MMkay", nil) otherButtonTitles:nil] show];
        }
        else {
            [self performSegueWithIdentifier:@"pushSearchTable" sender:sender];
        }
    }];
}

@end

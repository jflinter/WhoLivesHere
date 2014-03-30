//
//  FNMAppDelegate.m
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/23/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMAppDelegate.h"
#import "FNMFriendTableViewController.h"
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

@implementation FNMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    if ([[FBSession activeSession] isOpen]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        FNMFriendTableViewController *controller = (FNMFriendTableViewController*)[mainStoryboard
                                                           instantiateViewControllerWithIdentifier: @"FNMFriendTableViewController"];
        [navController pushViewController:controller animated:NO];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end

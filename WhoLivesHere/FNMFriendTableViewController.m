//
//  FNMFriendTableViewController.m
//  FriendsNearMe
//
//  Created by Jack Flintermann on 2/23/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "FNMFriendTableViewController.h"
#import "FNMFacebookFriend.h"
#import "FNMFriendClient.h"
#import "FNMFriendTableViewCell.h"

@interface FNMFriendTableViewController ()<UISearchBarDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) UISearchBar *searchBar;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, readwrite) NSArray *friendsList;
@property(nonatomic, readwrite) FNMFacebookFriend *selectedFriend;
@end

@implementation FNMFriendTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _friendsList = @[];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView = activityIndicator;
    self.activityIndicatorView.frame = ({
        CGRect rect = self.activityIndicatorView.frame;
        rect.origin.x = (self.tableView.frame.size.width - rect.size.width) / 2 ;
        rect.origin.y = self.searchBar.frame.size.height + 15;
        rect;
    });
    self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.tableView addSubview:self.activityIndicatorView];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = NSLocalizedString(@"I'm looking for friends in...", nil);
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    [searchBar sizeToFit];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    searchBar.delegate = self;
    self.searchBar = searchBar;
    self.navigationItem.titleView = searchBar;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void) willBeginSearching {
    [self clearResults];
    [self.activityIndicatorView startAnimating];
}

- (void) clearResults {
    self.friendsList = @[];
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
}

- (void) didEndSearching {
    [self.activityIndicatorView stopAnimating];
    [self.tableView reloadData];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *template = self.friendsList.count == 1 ? NSLocalizedString(@"%i Friend Found", nil) : NSLocalizedString(@"%i Friends Found", nil);
    label.text = [NSString stringWithFormat:template, self.friendsList.count];
    self.tableView.tableFooterView = label;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FNMFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    FNMFacebookFriend *friend = [self.friendsList objectAtIndex:indexPath.row];
    [cell configureWithFriend:friend];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedFriend = [self.friendsList objectAtIndex:indexPath.row];
    if (![[UIApplication sharedApplication] canOpenURL:self.selectedFriend.fbURL]) {
        // User doesn't have the FB app
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Install the Facebook app to view %@'s profile.", nil), self.selectedFriend.name];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't open profile", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"View in FB App", nil), nil];
    [actionSheet showInView:self.tableView];
}

# pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:self.selectedFriend.fbURL];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [self clearResults];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (!searchBar.text.length) {
        return;
    }
    [self willBeginSearching];
    [[FNMFriendClient sharedInstance] searchForFriends:searchBar.text withCallback:^(NSArray *results, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Whoops", nil) message:NSLocalizedString(@"Something went wrong while searching for your friends. Please check your Internet connection and try again!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
        else {
            self.friendsList = results;
#ifdef GENERATING_SCREENSHOTS
            _friendsList = @[
                             [[FNMFacebookFriend alloc] initWithResponseDictionary:@{@"name": @"Tim Cook", @"current_location": @{@"name": @"Cupertino, CA"}, @"mutual_friend_count": @(4)}],
                             [[FNMFacebookFriend alloc] initWithResponseDictionary:@{@"name": @"Jony Ive", @"current_location": @{@"name": @"Cupertino, CA"}, @"mutual_friend_count": @(3)}],
                             [[FNMFacebookFriend alloc] initWithResponseDictionary:@{@"name": @"Craig Federighi", @"current_location": @{@"name": @"Cupertino, CA"}, @"mutual_friend_count": @(500)}],
                             
                             
                             ];
#endif
        }
        [self didEndSearching];
    }];
}

@end

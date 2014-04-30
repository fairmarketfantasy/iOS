//
//  FFWideReceiverController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverController.h"
#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import "FFTeamAddCell.h"
#import "FFNoConnectionCell.h"
#import "FFRosterTableHeader.h"
#import "FFAccountHeader.h"
#import "FFStyle.h"
#import "FFPathImageView.h"
#import "FFPTController.h"
#import "FFAlertView.h"
#import "Reachability.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <libextobjc/EXTScope.h>
#import <libextobjc/EXTScope.h>
#import <FlatUIKit.h>
// model
#import "FFUser.h"
#import "FFRoster.h"
#import "FFPlayer.h"

@interface FFWideReceiverController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign) NSUInteger position;
@property(nonatomic, assign) NetworkStatus networkStatus;

@end

@implementation FFWideReceiverController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.position = 0;
    self.tableView = [[FFWideReceiverTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.players.count == 0) {
        [self fetchPlayersWithShowingAlert:NO completion:^{
            [self.tableView reloadData];
        }];
    }
}

#pragma mark

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self fetchPlayersWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }];
}

#pragma mark -

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if (internetStatus == NotReachable) {
            [self.tableView reloadData];
        } else {
            [self fetchPlayersWithShowingAlert:YES completion:^{
                [self.tableView reloadData];
            }];
        }
    }
}

#pragma mark - public

- (void)showPosition:(NSString*)position
{
    if (self.delegate.positions.count == 0) {
        return;
    }
    
    for (NSString* positionName in self.delegate.positions) {
        if ([positionName isEqualToString:position]) {
            [self selectPosition:[self.delegate.positions indexOfObject:positionName]];
            break;
        }
    }
}

#pragma mark - private

- (void)selectPosition:(NSUInteger)position
{
    self.position = position;
    [self fetchPlayersWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
    }];
}

- (void)fetchPlayersWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block
{
    if (self.networkStatus == NotReachable) {
        if (shouldShow) {
            [[FFAlertView noInternetConnectionAlert] showInView:self.view];
        }
        
        block();
        return;
    }
    
    if (!self.delegate.rosterId) {
        self.players = @[];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    __block FFAlertView* alert = nil;
    if (shouldShow) {
        alert = [[FFAlertView alloc] initWithTitle:@"Loading Players"
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
    }
    
    @weakify(self)
    [FFPlayer fetchPlayersForRoster:self.delegate.rosterId
                           position:self.delegate.positions[self.position]
                     removedBenched:self.delegate.autoRemovedBenched
                            session:self.session
                            success:
     ^(id successObj) {
         @strongify(self)
         self.players = successObj;
         //         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
         //                       withRowAnimation:UITableViewRowAnimationAutomatic];
         if(alert)
             [alert hide];
         if (block)
             block();
     }
                            failure:
     ^(NSError *error) {
         @strongify(self)
         self.players = @[];
         //         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
         //                       withRowAnimation:UITableViewRowAnimationAutomatic];
         if(alert)
             [alert hide];
         if (block)
             block();
         /* !!!: disable error alerts NBA-659
          [[[FFAlertView alloc] initWithError:error
          title:nil
          cancelButtonTitle:nil
          okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
          autoHide:YES]
          showInView:self.navigationController.view];
          */
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return self.networkStatus == NotReachable ? 1 : 2;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return self.networkStatus == NotReachable ? 1 : self.players.count;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        //navigation bar height + status bar height = 64
        return self.networkStatus == NotReachable ? [UIScreen mainScreen].bounds.size.height - 64.f : 60.f;
    }
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (self.networkStatus == NotReachable) {
            FFNoConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                       forIndexPath:indexPath];
            return cell;
         }
        
        FFWideReceiverCell* cell = [tableView dequeueReusableCellWithIdentifier:kWideRecieverCellIdentifier
                                                                   forIndexPath:indexPath];
        [cell setItems: self.delegate.positions ? self.delegate.positions : @[]];
        if (cell.segments.numberOfSegments > self.position) {
            cell.segments.selectedSegmentIndex = self.position;
        }
        [cell.segments addTarget:self
                          action:@selector(segments:)
                forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    FFTeamAddCell* cell = [tableView dequeueReusableCellWithIdentifier:kTeamAddCellIdentifier
                                                          forIndexPath:indexPath];
    if (self.players.count > indexPath.row) {
        __block FFPlayer* player = self.players[indexPath.row];

        cell.titleLabel.text =  player.team;
        cell.nameLabel.text = player.name;
        cell.costLabel.text = [FFStyle.priceFormatter stringFromNumber:@([player.buyPrice floatValue])];
        BOOL benched = player.benched.integerValue == 1;
        UIColor* avatarColor = benched ? [FFStyle brightOrange] : [FFStyle brightGreen];
        cell.avatar.borderColor = avatarColor;
        cell.avatar.pathColor = avatarColor;
        [cell.avatar setImageWithURL: [NSURL URLWithString:player.headshotURL]
                    placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
         usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [cell.avatar draw];
        cell.benched.hidden = !benched;
        cell.PTButton.hidden = benched;
        @weakify(self)
        [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           @strongify(self)
                           [self.parentViewController performSegueWithIdentifier:@"GotoPT"
                                                                          sender:player]; // TODO: refactode it (?)
                       }];
        [cell.addButton setAction:kUIButtonBlockTouchUpInside
                        withBlock:^{
                            @strongify(self)
                            if (self.delegate) {
                                [self.delegate addPlayer:player];
                            }
                        }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: implement
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        NSString* positionName = @"";
        if (self.delegate && self.networkStatus != NotReachable) {
            positionName = self.delegate.positions[self.position];
            NSString* positionFullName = self.delegate.positionsNames[positionName];
            if (positionFullName) {
                positionName = positionFullName;
            }
        }
        view.titleLabel.text = NSLocalizedString(positionName, nil);
        view.priceLabel.text = self.delegate ?
        [[FFStyle priceFormatter] stringFromNumber:@(self.delegate.rosterSalary)] : @"";
        view.priceLabel.textColor = self.delegate.rosterSalary > 0.f
        ? [FFStyle brightGreen] : [FFStyle brightRed];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40.f;
    }
    return 0.f;
}

#pragma mark - button actions

- (void)segments:(FUISegmentedControl*)segments
{
    [self selectPosition:segments.selectedSegmentIndex];
}

@end

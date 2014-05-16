//
//  FFRosterViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFRosterViewController.h"
#import "FFRoster.h"
#import "FFRosterTable.h"
#import "FFSessionViewController.h"
#import "FFContestViewController.h"
#import <A2StoryboardSegueContext/A2StoryboardSegueContext.h>
#import "FFAlertView.h"
#import "FFRosterCell.h"
#import "FFRosterTableHeader.h"

@interface FFRosterViewController () <UITableViewDataSource, UITableViewDelegate, SBDataObjectResultSetDelegate>

@property(nonatomic) FFRosterTable* tableView;
@property(nonatomic) SBDataObjectResultSet* rosters;
@property(nonatomic) SBDataObjectResultSet* historicalRosters;
@property(nonatomic) NSTimer* refreshTimer;

@end

@implementation FFRosterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[FFRosterTable alloc] initWithFrame:self.view.bounds];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        id topGuide = self.topLayoutGuide;
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(_tableView, topGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_tableView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    }
//    FFBalanceButton* balanceView = [FFBalanceButton buttonWithDataSource:self.sessionController];
//    [balanceView addTarget:self
//                    action:@selector(showBalance:)
//          forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:balanceView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SBModelQuery* query = [[[[[[self.session queryBuilderForClass:[FFRoster class]]
                                   property:@"ownerId"
                                  isEqualTo:self.session.user.objId]
                                     property:@"state"
                                 isNotEqualTo:@"finished"]
                                orderByProperties:@[
                                                      @"objId"
                                                  ]]
                               sort:SBModelDescending] query];

    _rosters = [FFRoster getBulkPath:@"/rosters/mine"
                          cacheQuery:query
                         withSession:self.session
                          authorized:YES];
    _rosters.clearsCollectionBeforeSaving = YES;
    _rosters.delegate = self;

    SBModelQuery* hQuery = [[[[[[self.session queryBuilderForClass:[FFRoster class]]
                                    property:@"ownerId"
                                   isEqualTo:self.session.user.objId]
                                   property:@"state"
                                  isEqualTo:@"finished"]
                                 orderByProperties:@[
                                                       @"objId"
                                                   ]]
                                sort:SBModelDescending] query];
    _historicalRosters = [FFRoster getBulkPath:@"/rosters/mine?historical=y"
                                    cacheQuery:hQuery
                                   withSession:self.session
                                    authorized:YES];
    _historicalRosters.delegate = self;

    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)2.f
                                                         target:self
                                                       selector:@selector(refreshLiveData)
                                                       userInfo:nil
                                                        repeats:YES];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GotoContest"]) {
        FFRoster* roster = segue.context;
        ((FFContestViewController*)segue.destinationViewController).roster = roster;
    }
}

#pragma mark - private

- (void)showBalance:(UIButton*)seder
{
    [self performSegueWithIdentifier:@"GotoTokenPurchase"
                              sender:nil];
}

- (void)refreshLiveData
{
    [self.rosters performSelectorOnMainThread:@selector(refresh)
                                   withObject:nil
                                waitUntilDone:NO];
}

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    if (resultSet == _rosters) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationNone];
    } else if (resultSet == _historicalRosters) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)fetchRoster:(FFRoster*)roster
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Loading...", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];

    [FFMarket get:roster.marketId
          session:self.session
          success:^(id successObj)
    {
        roster.market = successObj;
        [roster save];
        [alert hide];
        [self performSegueWithIdentifier:@"GotoContest"
                                  sender:nil
                                 context:roster];
    }
failure:
    ^(NSError * error)
    {
        [alert hide];
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
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.rosters count];
    } else if (section == 1) {
        return [self.historicalRosters count];
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FFRosterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RosterCell"
                                                         forIndexPath:indexPath];

//    FFRoster* roster = nil;
//    if (indexPath.section == 0) {
//        roster = [self.rosters objectAtIndex:indexPath.row];
//    } else if (indexPath.section == 1) {
//        roster = [self.historicalRosters objectAtIndex:indexPath.row];
//    }

//    cell.roster = roster;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return 50.f;
}

- (UIView*)tableView:(UITableView*)tableView
    viewForHeaderInSection:(NSInteger)section
{
    FFRosterTableHeader* header = [[FFRosterTableHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 50.f)];
    NSString* headerTitle = @"";
    if (section == 0) {
        headerTitle = NSLocalizedString(@"Live Contest Entries", nil);
    } else if (section == 1 && self.historicalRosters.count > 0) {
        headerTitle = NSLocalizedString(@"Past Entries", nil);
    }
    header.titleLabel.text = headerTitle;
    return header;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    FFRoster* roster = nil;
    if (indexPath.section == 0) {
        roster = [self.rosters objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        roster = [self.historicalRosters objectAtIndex:indexPath.row];
    }

    if (!roster.market) {
        [self fetchRoster:roster];
    } else {
        [self performSegueWithIdentifier:@"GotoContest"
                                  sender:self
                                 context:roster];
    }
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

@end

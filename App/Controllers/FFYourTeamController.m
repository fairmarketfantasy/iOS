//
//  FFYourTeamController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFYourTeamController.h"
#import "FFSessionViewController.h"
#import "FFTeamTable.h"
#import "FFAutoFillCell.h"
#import "FFMarketsCell.h"
#import "FFTeamCell.h"
#import "FFTeamTradeCell.h"
#import "FFAlertView.h"
#import "FFRosterTableHeader.h"
#import "FFAccountHeader.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFPathImageView.h"
#import "FFMarketSelector.h"
#import "FFCollectionMarketCell.h"
#import <libextobjc/EXTScope.h>
// models
#import "FFUser.h"
#import "FFRoster.h"

@interface FFYourTeamController () <UITableViewDataSource, UITableViewDelegate,
FFMarketSelectorDelegate, SBDataObjectResultSetDelegate>
// models
@property(nonatomic) FFRoster* roster;
@property(nonatomic) FFMarket* selectedMarket;
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;

@end

@implementation FFYourTeamController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[FFTeamTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    self.marketsSet = [FFMarket getBulkWithSession:self.session
                                        authorized:YES];
    self.marketsSet.delegate = self;
    [self updateMarkets];
    // roster
    self.tryCreateRosterTimes = 3;
    [self createRoster];
    [self updateHeader];
}

#pragma mark - private

// TODO: move it to model
- (NSArray*)positions
{
    return [self.roster.positions componentsSeparatedByString:@","];
}

#pragma mark - public

- (void)createRoster
{
    if (!self.selectedMarket) {
        return;
    }
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Creating Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [FFRoster createNewRosterForMarket:self.selectedMarket.objId
                               session:self.session
                               success:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                       withRowAnimation:UITableViewRowAnimationAutomatic];
         [alert hide];
     }
                               failure:
     ^(NSError * error) {
         @strongify(self)
         if (self.tryCreateRosterTimes > 0) {
             [alert hide];
             self.tryCreateRosterTimes--;
             [self createRoster];
         } else {
             self.roster = nil;
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                           withRowAnimation:UITableViewRowAnimationAutomatic];
             [alert hide];
             [[[FFAlertView alloc] initWithError:error
                                           title:nil
                               cancelButtonTitle:nil
                                 okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                        autoHide:YES]
              showInView:self.navigationController.view];
         }
     }];
}

- (void)updateHeader
{
    FFAccountHeader* header = (FFAccountHeader*)self.tableView.tableHeaderView;
    if (![header isKindOfClass:[FFAccountHeader class]]) {
        return;
    }
    [header.avatar setImageWithURL: [NSURL URLWithString:self.session.user.imageUrl]
                  placeholderImage: [UIImage imageNamed:@"defaultuser"]
       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [header.avatar draw];

    header.nameLabel.text = self.session.user.name;
    header.walletLabel.text = [FFStyle.funbucksFormatter
                               stringFromNumber:@(self.session.user.balance.floatValue)];
    NSDate* join = self.session.user.joinDate;
    header.dateLabel.text = join ? [NSString stringWithFormat:@"Member Since %@",
                                    [FFStyle.dateFormatter stringFromDate:join]] : @"";
    header.pointsLabel.text = [NSString stringWithFormat:@"%i points", self.session.user.totalPoints.integerValue];
    header.winsLabel.text = [NSString stringWithFormat:@"%i wins (%.2f win %%)",
                             self.session.user.totalWins.integerValue,
                             self.session.user.winPercentile.floatValue];
}

- (void)updateMarkets
{
    self.marketsSet.clearsCollectionBeforeSaving = NO;
    [self.marketsSet fetchType:FFMarketTypeRegularSeason];
    self.marketsSet.clearsCollectionBeforeSaving = YES;
    [self.marketsSet fetchType:FFMarketTypeSingleElimination];
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
        return 2;
    }
    return [self positions].count;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60.f;
        }
        return 50.f;
    }
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case 0: {
        if (indexPath.row == 0) {
            FFMarketsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MarketsCell"
                                                                  forIndexPath:indexPath];
            cell.marketSelector.delegate = self;
            [cell.marketSelector reloadData];
            if (self.selectedMarket && self.markets) {
                NSUInteger selectedMarket = [self.markets indexOfObject:self.selectedMarket];
                if (selectedMarket != NSNotFound) {
                    cell.marketSelector.selectedMarket = selectedMarket;
                }
            }
            return cell;
        }
        FFAutoFillCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AutoFillCell"
                                                               forIndexPath:indexPath];
        [cell.autoFillButton addTarget:self
                                action:@selector(autoFill:)
                      forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    case 1: {
        NSString* position = [self positions][indexPath.row];
        for (NSDictionary* player in self.roster.players) { // TODO: make players MODEL(!!!)
            if ([player[@"position"] isEqualToString:position]) {
                FFTeamTradeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTradeCell"
                                                                        forIndexPath:indexPath];
                cell.titleLabel.text = player[@"team"];
                cell.nameLabel.text = player[@"name"];
                cell.costLabel.text = [FFStyle.priceFormatter
                                       stringFromNumber:@([player[@"purchase_price"] floatValue])];
                cell.centLabel.text = @"";
                [cell.avatar setImageWithURL: [NSURL URLWithString:player[@"headshot_url"]]
                              placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
                   usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [cell.avatar draw];

                return cell;
            }
        }
        FFTeamCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamCell"
                                                           forIndexPath:indexPath];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", position,
                                NSLocalizedString(@"Not Selected", nil)];
        return cell;
    }
    default:
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: implement
}

- (UIView *)tableView:(UITableView*)tableView
viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = FFRosterTableHeader.new;
        view.titleLabel.text = NSLocalizedString(@"Your Team", nil);
        view.priceLabel.text = NSLocalizedString(@"$-100000", nil);
        view.priceLabel.textColor = [FFStyle brightRed];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40.f;
    }
    return 0.f;
}

#pragma mark - button actions

- (void)autoFill:(UIButton*)button
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Auto Fill Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster autofillSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                       withRowAnimation:UITableViewRowAnimationAutomatic];
         [alert hide];
     }
                         failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         [[[FFAlertView alloc] initWithError:error
                                       title:nil
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
     }];
}

#pragma mark - FFMarketSelectorDelegate

- (NSArray*)markets
{
    return self.marketsSet.allObjects;
}

- (void)marketSelected:(FFMarket*)selectedMarket
{
    self.selectedMarket = selectedMarket;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tryCreateRosterTimes = 3;
    [self createRoster];
}

#pragma mark - SBDataObjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    if (self.markets.count > 0) {
        [self marketSelected:self.markets.firstObject];
    } else {
        self.selectedMarket = nil;
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.markets.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    FFCollectionMarketCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MarketCell"
                                                                             forIndexPath:indexPath];
    if (self.markets.count > indexPath.item) {
        FFMarket* market = self.markets[indexPath.item];
        cell.marketLabel.text = market.name && market.name.length > 0 ? market.name : NSLocalizedString(@"Market", nil);
        cell.timeLabel.text = [[FFStyle marketDateFormatter] stringFromDate:market.startedAt];
    }
    return cell;
}

@end

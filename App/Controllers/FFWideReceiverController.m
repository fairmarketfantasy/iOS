//
//  FFWideReceiverController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverController.h"
#import "FFYourTeamDataSource.h"
#import "FFPagerController.h"
#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import "FFTeamAddCell.h"
#import "FFNoConnectionCell.h"
#import "FFCollectionMarketCell.h"
#import "FFMarketsCell.h"
#import "FFRosterTableHeader.h"
#import "FFMarketSelector.h"
#import "FFAccountHeader.h"
#import "FFStyle.h"
#import "FFMarket.h"
#import "FFDate.h"
#import "FFMarketSet.h"
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

@interface FFWideReceiverController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FFMarketSelectorDelegate, FFMarketSelectorDataSource>

@property(nonatomic, assign) NSUInteger position;
@property(nonatomic, assign) NetworkStatus networkStatus;

@property(nonatomic, strong) UIPickerView *picker;

@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;

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
    
    //reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    //custom picker
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 162.f)];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    CGAffineTransform t0 = CGAffineTransformMakeTranslation(self.picker.bounds.size.width/2, self.picker.bounds.size.height/2);
	CGAffineTransform s0 = CGAffineTransformMakeScale(1.0, 0.47);
	CGAffineTransform t1 = CGAffineTransformMakeTranslation(-self.picker.bounds.size.width/2, -self.picker.bounds.size.height/2);
	self.picker.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1));
    self.picker.backgroundColor = [FFStyle darkGrey];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.picker reloadAllComponents];
    
    if (self.players.count == 0) {
        [self fetchPlayersWithShowingAlert:NO completion:^{
            [self.tableView reloadData];
        }];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self fetchPlayersWithShowingAlert:NO completion:^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }];
}

#pragma mark -

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if ((internetStatus != NotReachable && previousStatus == NotReachable) ||
            (internetStatus == NotReachable && previousStatus != NotReachable)) {
            
            if (internetStatus == NotReachable) {
                [self.tableView reloadData];
            } else {
                [self fetchPlayersWithShowingAlert:YES completion:^{
                    [self.tableView reloadData];
                }];
            }
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
            NSUInteger selectedIndex = [self.delegate.positions indexOfObject:positionName];
            [self.picker selectRow:selectedIndex inComponent:0 animated:YES];
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

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.delegate.positions.count;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 54.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 54.f)];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.textColor = [UIColor clearColor];
        pickerLabel.font = [FFStyle blockFont:30.0f];
        pickerLabel.textColor = [UIColor whiteColor];
    }
    
    NSString *positionName = self.delegate.positions[row];
    pickerLabel.text = self.delegate.positionsNames[positionName];
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self selectPosition:row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return self.networkStatus == NotReachable ? 1 : 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return self.networkStatus == NotReachable ? 1 : self.players.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60.f;
        } else {
            //navigation bar height + status bar height = 64
            return self.networkStatus == NotReachable ? [UIScreen mainScreen].bounds.size.height - 64.f : 76.f;
        }
    }
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (self.networkStatus == NotReachable) {
                FFNoConnectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                           forIndexPath:indexPath];
                return cell;
            }
            return [self provideMarketsCellForTable:tableView atIndexPath:indexPath];
        } else if (indexPath.row == 1) {
            //            [self provideWideRecieverCellForTable:tableView atIndexPath:indexPath];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerCellIdentifier forIndexPath:indexPath];
            [cell addSubview:self.picker];
            return cell;
        }
    } else if (indexPath.section == 1) {
        return [self provideTeamAddCellForTable:tableView atIndexPath:indexPath];
    }
    
    return nil;
}

#pragma mark - Cells

- (FFMarketsCell *)provideMarketsCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFMarketsCell* cell = [tableView dequeueReusableCellWithIdentifier:kMarketsCellIdentifier
                                                          forIndexPath:indexPath];
    cell.marketSelector.dataSource = self;
    cell.marketSelector.delegate = self;
    [cell.marketSelector reloadData];
    if ([self.dataSource getSelectedMarket] && self.markets) {
//        _noGamesAvailable = NO;
        cell.contentView.userInteractionEnabled = YES;
        [cell setNoGamesLabelHidden:YES];
        NSUInteger selectedMarket = [self.markets indexOfObject:[self.dataSource getSelectedMarket]];
        if (selectedMarket != NSNotFound) {
            [cell.marketSelector updateSelectedMarket:selectedMarket
                                             animated:NO] ;
        }
    } else if (self.markets.count == 0) {
        if (self.networkStatus == NotReachable) {
            [cell setNoGamesLabelHidden:NO];
            cell.contentView.userInteractionEnabled = NO;
        }
    }
    
    return cell;
}

- (FFTeamAddCell *)provideTeamAddCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
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

- (FFWideReceiverCell *)provideWideRecieverCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - FFMarketSelectorDataSource

- (NSArray*)markets
{
    return [self.dataSource availableMarkets];
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
    if (self.markets.count > indexPath.item && self.networkStatus != NotReachable) {
        FFMarket* market = self.markets[indexPath.item];
        [cell showLabels];
        cell.marketLabel.text = market.name && market.name.length > 0 ? market.name : NSLocalizedString(@"Market", nil);
        cell.timeLabel.text = [[FFStyle marketDateFormatter] stringFromDate:market.startedAt];
    } else if (self.markets.count == 0 || self.networkStatus == NotReachable) {
        [cell hideLabels];
    }
    
    return cell;
}

#pragma mark - FFMarketSelectorDelegate

- (void)marketSelected:(FFMarket*)selectedMarket
{
    [self.dataSource setupSelectedMarket:selectedMarket];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tryCreateRosterTimes = 3;

//    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@""
//                                                           messsage:nil
//                                                       loadingStyle:FFAlertViewLoadingStylePlain];
//    [alert showInView:self.navigationController.view];
//    [self.dataSource createRosterWithCompletion:^{
//        [alert hide];
//        [self fetchPlayersWithShowingAlert:NO completion:^{
//            [self.tableView reloadData];
//        }];
//    }];
}

@end

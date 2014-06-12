//
//  FFPlayersController.m
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPlayersController.h"
#import "FFYourTeamDataSource.h"
#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import "FFTeamAddCell.h"
#import "FFNoConnectionCell.h"
#import "FFCollectionMarketCell.h"
#import "FFMarketsCell.h"
#import "FFAutoFillCell.h"
#import "FFRosterTableHeader.h"
#import "FFMarketSelector.h"
#import "FFAccountHeader.h"
#import "FFStyle.h"
#import "FFMarket.h"
#import "FFDate.h"
#import "FFMarketSet.h"
#import "FFPathImageView.h"
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
#import "FFTeam.h"

@interface FFPlayersController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource,
UIPickerViewDelegate, FFMarketSelectorDelegate, FFMarketSelectorDataSource>

@property(nonatomic, assign) NSUInteger position;
@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) BOOL isServerError;

@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;

@property(nonatomic, strong) UIPickerView *picker;

@end

@implementation FFPlayersController

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
    self.picker.showsSelectionIndicator = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? NO : YES;
    
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

- (void)resetPosition
{
    self.position = 0;
    [self.picker selectRow:0 inComponent:0 animated:NO];
}

- (void)reloadWithServerError:(BOOL)isError
{
    self.isServerError = isError;
    [self.picker reloadAllComponents];
    [self.tableView reloadData];
}

- (void)showPosition:(NSString*)position
{
    if ([self.dataSource uniquePositions].count == 0) {
        return;
    }
    
    for (NSString* positionName in [self.dataSource uniquePositions]) {
        if ([positionName isEqualToString:position]) {
            [self selectPosition:[[self.dataSource uniquePositions] indexOfObject:positionName]];
            NSUInteger selectedIndex = [[self.dataSource uniquePositions] indexOfObject:positionName];
            [self.picker selectRow:selectedIndex inComponent:0 animated:YES];
            break;
        }
    }
}

#pragma mark - private

- (BOOL)isSomethingWrong
{
    return (self.networkStatus == NotReachable ||
            self.isServerError ||
//            self.dataSource.unpaidSubscription == YES ||
            self.markets.count == 0);
}

- (void)selectPosition:(NSUInteger)position
{
    self.position = position;
    [self fetchPlayersWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
    }];
}

- (void)fetchPlayersWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block
{
    if ([self isSomethingWrong]) {
        block();
        return;
    }
    
    if (![self.dataSource.currentRoster objId]) {
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
    
    __block BOOL shouldRemoveBenched = [[self.dataSource currentRoster] removeBenched].integerValue == 1;
    
    @weakify(self)
    [FFPlayer fetchPlayersForRoster:[self.dataSource rosterId]
                           position:[self.dataSource uniquePositions][self.position]
                     removedBenched:shouldRemoveBenched
                            session:self.session
                            success:
     ^(id successObj) {
         @strongify(self)
         self.isServerError = NO;
         self.players = successObj;
         if(alert)
             [alert hide];
         if (block)
             block();
     }
                            failure:
     ^(NSError *error) {
         @strongify(self)
         self.players = @[];
         if(alert)
             [alert hide];
         if (block)
             block();
     }];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.dataSource uniquePositions].count;
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
        pickerLabel.textColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor clearColor] : [FFStyle darkGrey];
        pickerLabel.font = [FFStyle blockFont:30.0f];
        pickerLabel.textColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor whiteColor] : [UIColor blackColor];
    }
    
    NSString *positionName = [self.dataSource uniquePositions][row];
    pickerLabel.text = self.dataSource.positionsNames[positionName];
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self selectPosition:row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [self isSomethingWrong] ? 1 : 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([self isSomethingWrong]) {
            return 1;
        }
        
        return 2;
    }
    
    return self.players.count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //navigation bar height + status bar height = 64
            return [self isSomethingWrong] ? [UIScreen mainScreen].bounds.size.height - 64.f : 60.f;
        } else {
            return 76.f;
        }
    }

    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([self isSomethingWrong]) {
                FFNoConnectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                           forIndexPath:indexPath];
                NSString *message = nil;
                if (self.networkStatus == NotReachable) {
                    message = @"No Internet Connection";
                } /*else if ([self.dataSource unpaidSubscription]) {
                    message = @"Your free trial has ended. We hope you have enjoyed playing. To continue please visit our site: https//:predictthat.com";
                }*/ else if (self.markets.count == 0) {
                    message = @"No Games Scheduled";
                }
                
                cell.message.text = message;
                return cell;
            }
            
            return [self provideMarketsCellForTable:tableView atIndexPath:indexPath];
        } else if (indexPath.row == 1) {
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

- (FFAutoFillCell *)provideAutoFillCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFAutoFillCell* cell = [tableView dequeueReusableCellWithIdentifier:kAutoFillCellIdentifier
                                                           forIndexPath:indexPath];
    [cell.autoFillButton addTarget:self
                            action:@selector(autoFill:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (FFMarketsCell *)provideMarketsCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFMarketsCell* cell = [tableView dequeueReusableCellWithIdentifier:kMarketsCellIdentifier
                                                          forIndexPath:indexPath];
    cell.marketSelector.dataSource = self;
    cell.marketSelector.delegate = self;
    [cell.marketSelector reloadData];
    if (self.dataSource.currentMarket && self.markets) {
        cell.contentView.userInteractionEnabled = YES;
        [cell setNoGamesLabelHidden:YES];
        NSUInteger selectedMarket = [self.markets indexOfObject:self.dataSource.currentMarket];
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
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ PPG %li", player.team, (long)[player.ppg integerValue]];
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
        cell.PTButton.hidden = (benched || [player.ppg integerValue] == 0) ? YES : NO;
        @weakify(self)
        [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           @strongify(self)
                           [self.dataSource showIndividualPredictionsForPlayer:player];
//                           [self.parentViewController performSegueWithIdentifier:@"GotoPT"
//                                                                          sender:player]; // TODO: refactode it (?)
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
    [cell setItems: [self.dataSource uniquePositions] ? [self.dataSource uniquePositions] : @[]];
    if (cell.segments.numberOfSegments > self.position) {
        cell.segments.selectedSegmentIndex = self.position;
    }
    [cell.segments addTarget:self
                      action:@selector(segments:)
            forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: implement
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        NSString* positionName = @"";
        if (self.delegate && self.networkStatus != NotReachable && [self.dataSource uniquePositions].count > 0) {
            positionName = [self.dataSource uniquePositions][self.position];
            NSString* positionFullName = self.dataSource.positionsNames[positionName];
            if (positionFullName) {
                positionName = positionFullName;
            }
        }
        view.titleLabel.text = positionName;
        view.priceLabel.text = self.delegate ?
        [[FFStyle priceFormatter] stringFromNumber:@([[self.dataSource currentRoster] remainingSalary].floatValue)] : @"";
        view.priceLabel.textColor = [[self.dataSource currentRoster] remainingSalary].floatValue > 0.f
        ? [FFStyle brightGreen] : [FFStyle brightRed];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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

- (void)autoFill:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Autofill" object:nil];
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
        cell.marketLabel.text = market.name && market.name.length > 0 ? market.name : @"Market";
        cell.timeLabel.text = [[FFStyle marketDateFormatter] stringFromDate:market.startedAt];
    }
    
    return cell;
}

#pragma mark - FFMarketSelectorDelegate

- (void)marketSelected:(FFMarket*)selectedMarket
{
    [self.dataSource setCurrentMarket:selectedMarket];
    self.tryCreateRosterTimes = 3;
}

@end

//
//  FFWCController.m
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCController.h"
#import "FFWCManager.h"
#import "FFWCCell.h"
#import "FFWCGameCell.h"
#import "FFNoConnectionCell.h"
#import "FFPathImageView.h"
#import "FFAlertView.h"
#import "FFRosterTableHeader.h"
#import "FFIndividualPrediction.h"
#import "FFWCGame.h"
#import "FFWCTeam.h"
#import "FFWCGroup.h"
#import "FFWCPlayer.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Reachability.h"

@interface FFWCController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    Reachability* internetReachability;
}

@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSString *selectedGroup;
@property (nonatomic, assign) NetworkStatus networkStatus;

@end

@implementation FFWCController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [FFStyle darkGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //custom picker
    if (self.category == FFWCGroupWinners) {
        [self setupPicker];
    }
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if (!success)
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)setupPicker
{
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

- (void)resetPicker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupPicker];
        [self.picker selectRow:0 inComponent:0 animated:NO];
    });
}

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self.delegate refreshDataShowingAlert:NO completion:^{
        [refreshControl endRefreshing];
    }];
}

#pragma mark

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        if (internetStatus == NotReachable && previousStatus != NotReachable)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
    }
}

- (BOOL)isSomethingWrong
{
    return ([self.errorDelegate isError] ||
            [self.errorDelegate isUnpaid] ||
            self.networkStatus == NotReachable);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isSomethingWrong])
        return 1;
    
    return self.category == FFWCGroupWinners ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSomethingWrong])
        return 1;
    
    if (self.category == FFWCGroupWinners) {
        if (section == 0) {
            return 1;
        } else {
            FFWCGroup *group = [self.candidates objectAtIndex:self.selectedCroupIndex];
            return group.teams.count;
        }
    } else {
        return self.candidates.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isSomethingWrong])
        return [UIScreen mainScreen].bounds.size.height - 64.f;
    
    if (self.category == FFWCGroupWinners) {
        return indexPath.section == 0 ? 76.f : 80.f;
    } else if (self.category == FFWCDailyWins) {
        return 100.f;
    } else {
        return 80.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self isSomethingWrong]) {
            FFNoConnectionCell* cell = [[FFNoConnectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNoConnectionCellIdentifier];
            NSString *message = nil;
            if (self.networkStatus == NotReachable) {
                message = @"No Internet Connection";
            } else if ([self.errorDelegate isUnpaid]) {
                message = [self.errorDelegate unpaidErrorMessage];
            } else {
                message = [self.errorDelegate errorMessage];
            }
            
            cell.message.text = message;
            return cell;
        }
        
        switch (self.category) {
            case FFWCCupWinner: {
                __block FFWCTeam *team = (FFWCTeam *)[self.candidates objectAtIndex:indexPath.row];
                FFWCCell *cell = [[FFWCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCCell"];
                [cell setupWithTeam:team];
                
                __weak FFWCController *weakSelf = self;
                [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                               withBlock:^{
                                   [weakSelf.delegate submitPredictionOnTeam:team inGame:nil category:self.category];
                               }];
                return cell;
            }
                
            case FFWCGroupWinners: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PickerCell"];
                [cell addSubview:self.picker];
                return cell;
            }
             
            case FFWCDailyWins: {
                FFWCGameCell *cell = [[FFWCGameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCGameCell"];
                __block FFWCGame *game = [self.candidates objectAtIndex:indexPath.row];
                [cell setupWithGame:game];
                
                __weak FFWCController *weakSelf = self;
                [cell.homePTButton setAction:kUIButtonBlockTouchUpInside
                                   withBlock:^{
                                       [weakSelf.delegate submitPredictionOnTeam:game.homeTeam inGame:game category:self.category];
                                   }];
                [cell.guestPTButton setAction:kUIButtonBlockTouchUpInside
                                    withBlock:^{
                                        [weakSelf.delegate submitPredictionOnTeam:game.guestTeam inGame:game category:self.category];
                                    }];
                
                return cell;
            }
                
            case FFWCMvp: {
                __block FFWCPlayer *player = (FFWCPlayer *)[self.candidates objectAtIndex:indexPath.row];
                FFWCCell *cell = [[FFWCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCCell"];
                [cell setupWithPlayer:player];
                
                __weak FFWCController *weakSelf = self;
                [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                               withBlock:^{
                                   [weakSelf.delegate submitPredictionOnPlayer:player category:self.category];
                               }];
                return cell;
            }
                
            default:
                return nil;
        }
    } else {
        FFWCGroup *group = [self.candidates objectAtIndex:self.selectedCroupIndex];
        __block FFWCTeam *team = [group.teams objectAtIndex:indexPath.row];
        FFWCCell *cell = [[FFWCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCCell"];
        [cell setupWithTeam:team];
        
        __weak FFWCController *weakSelf = self;
        [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           [weakSelf.delegate submitPredictionOnTeam:team inGame:nil category:self.category];
                       }];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isSomethingWrong])
        return 0.f;
    
    if ((self.category == FFWCGroupWinners && section == 1) || (self.category != FFWCGroupWinners && section == 0)) {
        return 40.f;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self isSomethingWrong])
        return nil;
    
    if ((self.category == FFWCGroupWinners && section == 1) || (self.category != FFWCGroupWinners && section == 0)) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        NSString *title = nil;
        switch (self.category) {
            case FFWCCupWinner:
                title = @"Win the Cup";
                break;
            case FFWCGroupWinners:
                title = @"Win Groups";
                break;
            case FFWCDailyWins:
                title = @"Daily Wins";
                break;
            case FFWCMvp:
                title = @"MVP";
                break;
                
            default:
                break;
        }
        view.titleLabel.text = title;
        return view;
    }
    return nil;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.candidates.count;
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
    
    FFWCGroup *group = (FFWCGroup *)[self.candidates objectAtIndex:row];
    pickerLabel.text = group.title;
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedCroupIndex = row;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

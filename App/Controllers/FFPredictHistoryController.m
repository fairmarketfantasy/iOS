//
//  FFPredictHistoryController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryController.h"
#import "FFNavigationBarItemView.h"
#import <FlatUIKit.h>
#import "FFPredictHistoryTable.h"
#import "FFPredictHistoryCell.h"
#import "FFPredictIndividualCell.h"
#import "FFNoConnectionCell.h"
#import "FFPredictHeader.h"
#import "FFRosterTableHeader.h"
#import "FFPredictionsSelector.h"
#import "FFStyle.h"
#import "FFPredictRosterPagerController.h"
#import "FFAlertView.h"
#import "Reachability.h"
#import "FFSessionManager.h"
// model
#import "FFPredictionSet.h"
#import "FFIndividualPrediction.h"
#import "FFRosterPrediction.h"
#import "FFMarket.h"
#import "FFFantasyGame.h"
#import "FFContestType.h"
#import "FFDate.h"

@interface FFPredictHistoryController () <UITableViewDataSource, UITableViewDelegate,
FFPredictionsProtocol, SBDataObjectResultSetDelegate, FFPredictHistoryProtocol>

@property(nonatomic, strong) UIButton* typeButton;
@property(nonatomic, strong) FFPredictHistoryTable* tableView;
@property(nonatomic, strong) FFPredictionsSelector* typeSelector;
// model
@property(nonatomic, strong) FFPredictionSet* individualActivePredictions;
@property(nonatomic, strong) FFPredictionSet* individualHistoryPredictions;
@property(nonatomic, strong) FFPredictionSet* rosterActivePredictions;
@property(nonatomic, strong) FFPredictionSet* rosterHistoryPredictions;

@property(nonatomic, assign) FFPredictionsType predictionType;
@property(nonatomic, assign) FFPredictionState predictionState;
@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) BOOL unpaid;
@property(nonatomic, assign) BOOL needToRefresh;

//pagination stuff
@property(nonatomic, strong) NSMutableArray *predictions;
@property(nonatomic, assign) NSUInteger pageNumber;
@property(nonatomic, assign) BOOL nextPageIsEmpty;

@end

@implementation FFPredictHistoryController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.predictions = [NSMutableArray array];
    self.pageNumber = 1;
    
    if ([[FFSessionManager shared].currentSportName isEqualToString:FOOTBALL_WC]) {
        self.predictionType = FFPredictionsTypeIndividual;
    } else {
        self.predictionType = FFPredictionsTypeRoster;
    }
    self.predictionState = FFPredictionStateSubmitted;
    self.typeSelector = FFPredictionsSelector.new;
    self.typeSelector.delegate = self;
    [self.view addSubview:self.typeSelector];
    // right bar item
    self.typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.typeButton.frame = CGRectMake(0.f, 0.f, 200.f, 44.f);
    [self.typeButton setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                               forState:UIControlStateNormal];
    [self.typeButton setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                               forState:UIControlStateHighlighted];
    self.typeButton.titleLabel.font = [FFStyle blockFont:19.f];
    self.typeButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, self.typeButton.frame.size.width - 37.f, 0.f, 0.f);
    self.typeButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 0.f, 0.f, 37.f);
    [self.typeButton addTarget:self
                        action:@selector(showOrHideTypeSelectorIfNeeded)
              forControlEvents:UIControlEventTouchUpInside];
    self.typeButton.contentMode = UIViewContentModeScaleAspectFit;
    
    // table view
    self.tableView = [[FFPredictHistoryTable alloc] initWithFrame:self.view.bounds];
    self.tableView.historyDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.typeSelector];
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusHasChanged:) name:kReachabilityChangedNotification object:nil];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    self.needToRefresh = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    self.individualActivePredictions = [[FFPredictionSet alloc] initWithDataObjectClass:[FFIndividualPrediction class]
                                                                                session:self.session authorized:YES];
    self.individualActivePredictions.delegate = self;
    
    self.individualHistoryPredictions = [[FFPredictionSet alloc] initWithDataObjectClass:[FFIndividualPrediction class]
                                                                                 session:self.session authorized:YES];
    self.individualHistoryPredictions.delegate = self;
    
    self.rosterActivePredictions = [[FFPredictionSet alloc] initWithDataObjectClass:[FFRosterPrediction class]
                                                                            session:self.session authorized:YES];
    self.rosterActivePredictions.delegate = self;
    self.rosterHistoryPredictions = [[FFPredictionSet alloc] initWithDataObjectClass:[FFRosterPrediction class]
                                                                             session:self.session authorized:YES];
    self.rosterHistoryPredictions.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideTypeSelector];
    
    // title
    if ([[FFSessionManager shared].currentSportName isEqualToString:FOOTBALL_WC] == NO)
        self.navigationItem.titleView = self.typeButton;
    
    self.unpaid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Unpaidsubscription"] boolValue];
    
    if (self.networkStatus != NotReachable && self.needToRefresh) {
        [self refreshWithShowingAlert:YES completion:^{
            [self.tableView reloadData];
        }];        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.needToRefresh = NO;
    [super viewWillDisappear:animated];
    [self hideTypeSelector];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue
                 sender:(id)sender
{
    [super prepareForSegue:segue
                    sender:sender];
    if ([segue.identifier isEqualToString:@"GotoPredictRoster"]) {
        FFPredictRosterPagerController* vc = segue.destinationViewController;
        vc.prediction = (FFRosterPrediction*)sender;
    }
}

#pragma mark

- (void)networkStatusHasChanged:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if ((internetStatus != NotReachable && previousStatus == NotReachable) ||
            (internetStatus == NotReachable && previousStatus != NotReachable)) {
            
            if (internetStatus == NotReachable) {
                [self resetPaginationData];
                self.tableView.tableHeaderView = nil;
                [self.tableView reloadData];
            } else {
                [self.tableView setPredictionState:FFPredictionStateSubmitted];
                
                [self refreshWithShowingAlert:YES completion:^{
                    [self.tableView reloadData];
                }];
            }
        }
    }
}

#pragma mark -

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self resetPaginationData];
    [self refreshWithShowingAlert:NO completion:^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }];
}

#pragma mark - FFPredictionsProtocol

- (void)predictionsTypeSelected:(FFPredictionsType)type
{
    if (self.predictionType != type) {
        [self resetPaginationData];
    }
    self.predictionType = type;

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    [self refreshWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
    }];
    
    [self showOrHideTypeSelectorIfNeeded];
}

#pragma mark - button actions

- (void)showOrHideTypeSelectorIfNeeded
{
    if (!self.typeSelector.userInteractionEnabled) {
        [self showTypeSelector];
    } else {
        [self hideTypeSelector];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.networkStatus == NotReachable || self.unpaid) {
        return 1;
    } else {
        return self.predictions.count;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.networkStatus == NotReachable || self.unpaid) {
        FFNoConnectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                   forIndexPath:indexPath];
        NSString *message = self.networkStatus == NotReachable ? @"No Internet Connection" :
        @"Your free trial has ended. We hope you have enjoyed playing. To continue please visit our site: https//:predictthat.com";
        
        cell.message.text = message;

        return cell;
    }
    
    if (indexPath.row == self.predictions.count - 1 && self.predictions.count % 25 == 0 && self.nextPageIsEmpty == NO) {
        self.pageNumber++;
        [self refreshWithShowingAlert:YES completion:^{
            [self.tableView reloadData];
        }];
    }
    
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
        {
            FFPredictIndividualCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictIndividualCell"
                                                                            forIndexPath:indexPath];
            
            if (self.predictions.count > indexPath.row) {
                FFIndividualPrediction* prediction = self.predictions[indexPath.row];
                [cell setupWithPrediction:prediction];
            }
            return cell;
        }
            break;
        case FFPredictionsTypeRoster:
        {
            FFPredictHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictCell"
                                                                         forIndexPath:indexPath];
            if (self.predictions.count > indexPath.row) {
                __block FFRosterPrediction* prediction = self.predictions[indexPath.row];
                @weakify(self)
                [cell.rosterButton setAction:kUIButtonBlockTouchUpInside
                                   withBlock:^{
                                       @strongify(self)
                                       [self performSegueWithIdentifier:@"GotoPredictRoster"
                                                                 sender:prediction]; // TODO: refactode it (?)
                                   }];
                [cell setupWithPrediction:prediction];
            }
            return cell;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return (self.networkStatus == NotReachable || self.unpaid) ? [UIScreen mainScreen].bounds.size.height - 64.f : 160.f;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return (self.networkStatus == NotReachable || self.unpaid) ? 0.f : 40.f;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.networkStatus == NotReachable || self.unpaid)
        return nil;
    
    FFRosterTableHeader* header = FFRosterTableHeader.new;
    header.titleLabel.text = @"";
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
            header.titleLabel.text = @"Individual predictions";
            break;
        case FFPredictionsTypeRoster:
            header.titleLabel.text = @"Roster predictions";
            break;
        default:
            break;
    }
    header.titleLabel.frame = CGRectMake(header.titleLabel.frame.origin.x,
                                         header.titleLabel.frame.origin.y,
                                         320.f - 2 * header.titleLabel.frame.origin.x,
                                         60.f);
    return header;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - SBDataObjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    if (self.predictionType == FFPredictionsTypeRoster) {
        if (self.predictionState == FFPredictionStateSubmitted) {
            [self.predictions addObjectsFromArray:self.rosterActivePredictions.allObjects];
        } else {
            [self.predictions addObjectsFromArray:self.rosterHistoryPredictions.allObjects];
        }
    } else {
        if (self.predictionState == FFPredictionStateSubmitted) {
            [self.predictions addObjectsFromArray:self.individualActivePredictions.allObjects];
        } else {
            [self.predictions addObjectsFromArray:self.individualHistoryPredictions.allObjects];
        }
    }
    
    if (resultSet.allObjects.count == 0) {
        self.nextPageIsEmpty = YES;
    }
    
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - FFPredictHistoryProtocol

- (void)changeHistory:(FUISegmentedControl*)segments
{
    [self resetPaginationData];
    BOOL isHistory = segments.selectedSegmentIndex == 1;
    self.predictionState = isHistory ? FFPredictionStateFinished : FFPredictionStateSubmitted;
    [self refreshWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - private

- (void)resetPaginationData
{
    [self.predictions removeAllObjects];
    self.nextPageIsEmpty = NO;
    self.pageNumber = 1;
}

- (void)hideTypeSelector
{
    CGFloat typeSelectorHeight = 100.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.typeSelector.frame = CGRectMake(0.f,
                                              -typeSelectorHeight,
                                              self.view.bounds.size.width,
                                              typeSelectorHeight);
         self.typeSelector.alpha = 0.f;
         self.typeSelector.userInteractionEnabled = NO;
         [self.typeButton setImage:[UIImage imageNamed:@"hide"]
                          forState:UIControlStateNormal];
     }];
}

- (void)showTypeSelector
{
    CGFloat typeSelectorHeight = 100.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.typeSelector.frame = CGRectMake(0.f,
                                              0.f,
                                              self.view.bounds.size.width,
                                              typeSelectorHeight);
         self.typeSelector.alpha = 1.f;
         self.typeSelector.userInteractionEnabled = YES;
         [self.typeButton setImage:[UIImage imageNamed:@"show"]
                          forState:UIControlStateNormal];
     }];
}

- (void)refreshWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block
{
    if (self.networkStatus == NotReachable) {
        [self.tableView setPredictionState:self.predictionState];
        
        if (shouldShow) {
            [[FFAlertView noInternetConnectionAlert] showInView:self.view];
        }
        
        block();
        return;
    }
    
    __block FFAlertView* alert = nil;
    if (shouldShow) {
        alert = [[FFAlertView alloc] initWithTitle:@"Loading"
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
    }
    
    [self.tableView setPredictionState:self.predictionState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual: {
            if (self.predictionState == FFPredictionStateSubmitted) {
                [self.individualActivePredictions fetchWithParameters:@{
                                                                        @"page" : @(self.pageNumber)
                                                                        }
                                                           completion:^{
                                                               if (alert)
                                                                   [alert hide];
                                                               if (block)
                                                                   block();
                                                           }];
            } else {
                [self.individualHistoryPredictions fetchWithParameters:@{ @"historical" : @"true",
                                                                          @"page" : @(self.pageNumber)
                                                                          }
                                                            completion:^{
                                                                if (alert)
                                                                    [alert hide];
                                                                if (block)
                                                                    block();
                                                            }];
            }
            
            [self.typeButton setTitle:@"Individual"
                             forState:UIControlStateNormal];
        }
            break;
            
        case FFPredictionsTypeRoster: {
            if (self.predictionState == FFPredictionStateSubmitted) {
                [self.rosterActivePredictions fetchWithParameters:@{
                                                                    @"page" : @(self.pageNumber)
                                                                    }
                                                       completion:^{
                                                           if (alert)
                                                               [alert hide];
                                                           if (block)
                                                               block();
                                                       }];
            } else if (self.predictionState == FFPredictionStateFinished) {
                [self.rosterHistoryPredictions fetchWithParameters:@{ @"historical" : @"true",
                                                                      @"page" : @(self.pageNumber)
                                                                      }
                                                        completion:^{
                                                            if (alert)
                                                                [alert hide];
                                                            if (block)
                                                                block();
                                                        }]; // TODO: should be in one of MODELs                
            }
            
            [self.typeButton setTitle:@"Roster"
                             forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

@end

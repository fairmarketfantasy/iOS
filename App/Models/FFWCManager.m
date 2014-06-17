//
//  FFWCManager.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCManager.h"
#import "FFWCController.h"
#import "FFAlertView.h"
#import "FFSession.h"
#import "FFWCGame.h"
#import "FFWCGroup.h"
#import "FFWCTeam.h"
#import "FFWCPlayer.h"
#import "FFSession.h"
#import "FFIndividualPrediction.h"
#import "Reachability.h"

@interface FFWCManager() <FFWCDelegate> {
     Reachability* internetReachability;
}

@property (nonatomic, strong) FFWCController* dailyWinsController;
@property (nonatomic, strong) FFWCController* mvpController;
@property (nonatomic, strong) FFWCController* cupWinnerController;
@property (nonatomic, strong) FFWCController* groupWinnerController;

@property (nonatomic, strong) NSMutableArray *dailyWins; //array of WCTeams*
@property (nonatomic, strong) NSMutableArray *mvpCandidates; //array of WCPlayer*
@property (nonatomic, strong) NSMutableArray *groupWinners; //array of WCGroup*
@property (nonatomic, strong) NSMutableArray *cupWinners; //array of WCTeams*

@property (nonatomic, assign) NetworkStatus networkStatus;

@end

@implementation FFWCManager

- (id)initWithSession:(FFSession *)session
{
    self = [super initWithSession:session];
    if (self) {
        self.dailyWinsController = [[FFWCController alloc] init];
        self.cupWinnerController = [[FFWCController alloc] init];
        self.groupWinnerController = [[FFWCController alloc] init];
        self.mvpController = [[FFWCController alloc] init];
        
        self.dailyWinsController.delegate = self;
        self.cupWinnerController.delegate = self;
        self.groupWinnerController.delegate = self;
        self.mvpController.delegate = self;
        
        self.dailyWinsController.errorDelegate = self;
        self.cupWinnerController.errorDelegate = self;
        self.groupWinnerController.errorDelegate = self;
        self.mvpController.errorDelegate = self;
        
        //reachability
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusHasChanged:) name:kReachabilityChangedNotification object:nil];
        internetReachability = [Reachability reachabilityForInternetConnection];
        BOOL success = [internetReachability startNotifier];
        if (!success)
            DLog(@"Failed to start notifier");
        self.networkStatus = [internetReachability currentReachabilityStatus];
        
        [self getWorldCupData];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)networkStatusHasChanged:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if (internetStatus != NotReachable && previousStatus == NotReachable) {
            [self getWorldCupData];
        } 
    }
}

- (void)reloadControllers
{
    [self.dailyWinsController.tableView reloadData];
    [self.cupWinnerController.tableView reloadData];
    [self.groupWinnerController.tableView reloadData];
    [self.mvpController.tableView reloadData];
}

- (NSArray*)getViewControllers
{
    NSMutableArray *controllers = [NSMutableArray array];
    if (self.dailyWinsController.candidates.count > 0 || (self.dailyWinsController.candidates.count == 0 && self.networkStatus == NotReachable)) {
        [controllers addObject:self.dailyWinsController];
    }
    if (self.cupWinnerController.candidates.count > 0 || (self.cupWinnerController.candidates.count == 0 && self.networkStatus == NotReachable)) {
        [controllers addObject:self.cupWinnerController];
    }
    if (self.groupWinnerController.candidates.count > 0 || (self.groupWinnerController.candidates.count == 0 && self.networkStatus == NotReachable)) {
        [controllers addObject:self.groupWinnerController];
    }
    if (self.mvpController.candidates.count > 0 || (self.mvpController.candidates.count == 0 && self.networkStatus == NotReachable)) {
        [controllers addObject:self.mvpController];
    }
    
    if (controllers.count == 0) {
        [controllers addObject:self.dailyWinsController];
        [controllers addObject:self.cupWinnerController];
        [controllers addObject:self.groupWinnerController];
        [controllers addObject:self.mvpController];
    }
    
    return [NSArray arrayWithArray:controllers];
}

- (void)getWorldCupData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    __block FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                           messsage:@""
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    if (self.delegate.selectedController) {
        [alert showInView:self.delegate.selectedController.view];
    } else {
//        [alert showInView:self.dailyWinsController.view];
        FFWCController *firstController = [self getViewControllers].firstObject;
        [alert showInView:firstController.view];
    }
    
    [self fetchDataForSession:self.session
           dataWithCompletion:^(NSError *error) {
               [alert hide];
               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
               if (!error) {
                   self.errorType = FFErrorTypeNoError;
                   self.unpaidSubscription = NO;
                   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"Unpaidsubscription"];
                   [[NSUserDefaults standardUserDefaults] synchronize];
                   self.cupWinnerController.category = FFWCCupWinner;
                   self.cupWinnerController.candidates = [NSArray arrayWithArray:self.cupWinners];
                   
                   self.groupWinnerController.category = FFWCGroupWinners;
                   self.groupWinnerController.candidates = [NSArray arrayWithArray:self.groupWinners];
                   self.groupWinnerController.selectedCroupIndex = 0;
                   
                   self.dailyWinsController.category = FFWCDailyWins;
                   self.dailyWinsController.candidates = [NSArray arrayWithArray:self.dailyWins];
                   
                   self.mvpController.category = FFWCMvp;
                   self.mvpController.candidates = [NSArray arrayWithArray:self.mvpCandidates];
                   
                   [self.delegate shouldSetViewController:[self getViewControllers].firstObject
                                                direction:UIPageViewControllerNavigationDirectionForward
                                                 animated:YES
                                               completion:nil];
                   [self.delegate updatePagerView];
                   
                   [self reloadControllers];
                   [self.groupWinnerController resetPicker];
               } else {
                   [self handleError:error];
               }
           }];
}

- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(NSError *error))block
{
    NSString *path = @"home";
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:path
                                   paramters:@{@"sport" : FOOTBALL_WC}
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         NSLog(@" @{FFWCM} : JSON : %@", JSON);
                                         NSArray *dailyWinsDicts = [JSON objectForKey:@"daily_wins"];
                                         _dailyWins = [NSMutableArray arrayWithCapacity:dailyWinsDicts.count];
                                         for (NSDictionary *gameDict in dailyWinsDicts) {
                                             FFWCGame *game = [[FFWCGame alloc] initWithDictionary:gameDict];
                                             [_dailyWins addObject:game];
                                         }
                                         
                                         NSArray *groupWinnersDicts = [JSON objectForKey:@"win_groups"];
                                         _groupWinners = [NSMutableArray arrayWithCapacity:groupWinnersDicts.count];
                                         for (NSDictionary *groupDict in groupWinnersDicts) {
                                             FFWCGroup *group = [[FFWCGroup alloc] initWithDictionary:groupDict];
                                             [_groupWinners addObject:group];
                                         }
                                         
                                         NSArray *cupWinnersDicts = [JSON objectForKey:@"win_the_cup"];
                                         _cupWinners = [NSMutableArray arrayWithCapacity:cupWinnersDicts.count];
                                         for (NSDictionary *teamDict in cupWinnersDicts) {
                                             FFWCTeam *team = [[FFWCTeam alloc] initWithDictionary:teamDict];
                                             [_cupWinners addObject:team];
                                         }
                                         
                                         NSArray *mvpCandidatesDicts = [JSON objectForKey:@"mvp"];
                                         _mvpCandidates = [NSMutableArray arrayWithCapacity:mvpCandidatesDicts.count];
                                         for (NSDictionary *playerDict in mvpCandidatesDicts) {
                                             FFWCPlayer *player = [[FFWCPlayer alloc] initWithDictionary:playerDict];
                                             [_mvpCandidates addObject:player];
                                         }
                                         
                                         if (block)
                                             block(nil);
                                         
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         NSLog(@" {FFWCM} : error during fetching data : %@", error);
                                         if (block)
                                             block(error);
                                     }];
}

#pragma mark - Error handling

- (void)handleError:(NSError *)error
{
    NSString *errorDescription = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
    if ([errorDescription isEqualToString:@"Unpaid subscription!"]) {
        self.unpaidSubscription = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"Unpaidsubscription"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.errorType = FFErrorTypeUnknownServerError;
    }
    
    [self reloadControllers];
}

#pragma mark

- (void)disablePTInCupWinnersForTeam:(FFWCTeam *)team
{
    for (FFWCTeam *t in self.cupWinners) {
        if ([t.statsId isEqualToString:team.statsId])
            t.disablePT = YES;
    }
}

- (void)disablePTInGroupWinnersTeam:(FFWCTeam *)team
{
    for (FFWCGroup *group in self.groupWinners) {
        for (FFWCTeam *t in group.teams)
            if ([t.statsId isEqualToString:team.statsId])
                t.disablePT = YES;
    }
}

- (void)disablePTInDailyWinsForTeam:(FFWCTeam *)team inGame:(FFWCGame *)game
{
    for (FFWCGame *g in self.dailyWins) {
        if ([game.statsId isEqualToString:g.statsId]) {
            if ([game.homeTeam.statsId isEqualToString:team.statsId])
                game.homeTeam.disablePT = YES;
            else if ([game.guestTeam.statsId isEqualToString:team.statsId])
                game.guestTeam.disablePT = YES;
            else
                assert(NO);
        }
    }
}

- (void)disablePTForPlayer:(FFWCPlayer *)player
{
    for (FFWCPlayer *candidate in self.mvpCandidates) {
        if ([candidate.statsId isEqualToString:player.statsId])
            candidate.disablePT = YES;
    }
}

- (void)disablePTForTeam:(FFWCTeam *)team inGame:(FFWCGame *)game inCategory:(FFWCPredictionCategory)category
{
    switch (category) {
        case FFWCCupWinner:
            [self disablePTInCupWinnersForTeam:team];
            break;
        case FFWCGroupWinners:
            [self disablePTInGroupWinnersTeam:team];
            break;
        case FFWCDailyWins:
            [self disablePTInDailyWinsForTeam:team inGame:game];
            break;
            
        default:
            break;
    }
}

#pragma mark

- (NSString *)stringForWCCategory:(FFWCPredictionCategory)category
{
    switch (category) {
        case FFWCCupWinner:
            return @"win_the_cup";
        case FFWCGroupWinners:
            return @"win_groups";
        case FFWCDailyWins:
            return @"daily_wins";
        case FFWCMvp:
            return @"mvp";
            
        default:
            return nil;
    }
}

- (FFWCController *)controllerForWCCategory:(FFWCPredictionCategory)category
{
    switch (category) {
        case FFWCCupWinner:
            return self.cupWinnerController;
        case FFWCGroupWinners:
            return self.groupWinnerController;
        case FFWCDailyWins:
            return self.dailyWinsController;
        case FFWCMvp:
            return self.mvpController;
            
        default:
            return nil;
    }
}

#pragma mark - FFWCDelegate

- (void)submitPredictionOnPlayer:(FFWCPlayer *)player category:(FFWCPredictionCategory)category
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FOOTBALL_WC, @"sport",
                                   [self stringForWCCategory:category], @"prediction_type",
                                   player.statsId, @"predictable_id",
                                   nil];
    FFAlertView* confirmAlert = [[FFAlertView alloc] initWithTitle:nil
                                                         message:[NSString stringWithFormat:@"Predict %@ ?", player.name]
                                               cancelButtonTitle:@"Cancel"
                                                 okayButtonTitle:@"Submit"
                                                        autoHide:NO];
    [confirmAlert showInView:[self controllerForWCCategory:category].view];
    @weakify(confirmAlert)
    @weakify(self)
    confirmAlert.onOkay = ^(id obj) {
        @strongify(confirmAlert)
        @strongify(self)
        __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Individual Predictions"
                                                               messsage:nil
                                                           loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:[self controllerForWCCategory:category].view];
        
        [FFIndividualPrediction submitPredictionForSession:self.session
                                                    params:params
                                                   success:^(id successObj) {
                                                       self.errorType = FFErrorTypeNoError;
                                                       [self disablePTForPlayer:player];
                                                       [[self controllerForWCCategory:category].tableView reloadData];
                                                       [alert hide];
                                                       
                                                       FFAlertView* alert = [[FFAlertView alloc] initWithTitle:nil
                                                                                                       message:[successObj objectForKey:@"msg"]
                                                                                             cancelButtonTitle:nil
                                                                                               okayButtonTitle:@"OK"
                                                                                                      autoHide:YES];
                                                       [alert showInView:[self controllerForWCCategory:category].view];
                                                   } failure:^(NSError *error) {
                                                       [self handleError:error];
                                                       NSLog(@" {FFWCC} : submittion failed: %@", error);
                                                       [alert hide];
                                                   }];
        [confirmAlert hide];
    };
    
    confirmAlert.onCancel = ^(id obj) {
        @strongify(confirmAlert)
        [confirmAlert hide];
    };
}

- (void)submitPredictionOnTeam:(FFWCTeam *)team
                        inGame:(FFWCGame *)game
                      category:(FFWCPredictionCategory)category
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FOOTBALL_WC, @"sport",
                                   [self stringForWCCategory:category], @"prediction_type",
                                   team.statsId, @"predictable_id",
                                   nil];
    if (game) {
        [params addEntriesFromDictionary:@{
                                           @"game_stats_id" : game.statsId
                                           }];
    }
    
    FFAlertView* confirmAlert = [FFAlertView.alloc initWithTitle:nil
                                                         message:[NSString stringWithFormat:@"Predict %@ ?", team.name]
                                               cancelButtonTitle:@"Cancel"
                                                 okayButtonTitle:@"Submit"
                                                        autoHide:NO];
    [confirmAlert showInView:[self controllerForWCCategory:category].view];

    @weakify(confirmAlert)
    @weakify(self)
    confirmAlert.onOkay = ^(id obj) {
        @strongify(confirmAlert)
        @strongify(self)
        __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Individual Predictions"
                                                               messsage:nil
                                                           loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:[self controllerForWCCategory:category].view];
        
        [FFIndividualPrediction submitPredictionForSession:self.session
                                                    params:params
                                                   success:^(id successObj) {
                                                       self.errorType = FFErrorTypeNoError;
                                                       [self disablePTForTeam:team
                                                                       inGame:game
                                                                   inCategory:category];
                                                       [[self controllerForWCCategory:category].tableView reloadData];
                                                       [alert hide];
                                                       
                                                       FFAlertView* alert = [[FFAlertView alloc] initWithTitle:nil
                                                                                                       message:[successObj objectForKey:@"msg"]
                                                                                             cancelButtonTitle:nil
                                                                                               okayButtonTitle:@"OK"
                                                                                                      autoHide:YES];
                                                       [alert showInView:[self controllerForWCCategory:category].view];
                                                   } failure:^(NSError *error) {
                                                       [self handleError:error];
                                                       NSLog(@" {FFWCC} : submittion failed: %@", error);
                                                       [alert hide];
                                                   }];
        [confirmAlert hide];
    };
    
    confirmAlert.onCancel = ^(id obj) {
        @strongify(confirmAlert)
        [confirmAlert hide];
    };
}

@end

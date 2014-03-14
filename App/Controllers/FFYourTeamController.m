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
#import "FFUserBitCell.h"
#import "FFUserBitView.h"
#import "FFMarketsCell.h"
#import "FFTeamCell.h"
#import "FFAlertView.h"
// models
#import "FFUser.h"
#import "FFRoster.h"

@interface FFYourTeamController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) FFTeamTable* tableView;
@property(nonatomic) FFRoster* roster;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.roster = [self.session.user getInProgressRoster];
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
    return 10;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {

            BOOL isComplete = [self.roster.live integerValue] || [self.roster.market.state isEqualToString:@"complete"];
            return isComplete ? 195.f : 150.f;
        }
        return 44.f;
    }
    return 60.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case 0: {
        if (indexPath.row == 0) {
            FFUserBitCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UserBitCell"
                                                                  forIndexPath:indexPath];
            cell.userBit.user = self.session.user;
            [cell.userBit.inProgressRosterButton setAction:kUIButtonBlockTouchUpInside
                                                 withBlock:^{
                                                     if (!self.roster) {
                                                         return;
                                                     }
                                                     FFAlertView* loading = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Loading", nil)
                                                                                                      messsage:nil
                                                                                                  loadingStyle:FFAlertViewLoadingStylePlain];
                                                     [loading showInView:self.navigationController.view];
                                                     [self.roster refreshInBackgroundWithBlock:^(id successObj)
                                                      {
                                                          [loading hide];
                                                          [self performSegueWithIdentifier:@"GotoRoster"
                                                                                    sender:nil
                                                                                   context:successObj];
                                                      }
                                                                                  failure:
                                                      ^(NSError * error)
                                                      {
                                                          [loading hide];
                                                          [[[FFAlertView alloc] initWithError:error
                                                                                        title:nil
                                                                            cancelButtonTitle:nil
                                                                              okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                                                     autoHide:YES]
                                                           showInView:self.navigationController.view];
                                                      }];
                                                 }];
            return cell;
        }
        FFMarketsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MarketsCell"
                                                              forIndexPath:indexPath];
        return cell;
    }
    case 1: {
        FFTeamCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamCell"
                                                           forIndexPath:indexPath];
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
    // TODO: imaplement
}

@end

//
//  FFWideReceiverController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverController.h"
#import <libextobjc/EXTScope.h>
#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import <FlatUIKit.h>
#import "FFRosterTableHeader.h"
#import "FFTeamAddCell.h"
#import "FFStyle.h"
#import <libextobjc/EXTScope.h>
#import "FFAccountHeader.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFPathImageView.h"
#import "FFAlertView.h"
#import "FFPTController.h"
// model
#import "FFUser.h"
#import "FFRoster.h"
#import "FFPlayer.h"

@interface FFWideReceiverController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign) NSUInteger position;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchPlayers];
    [self.tableView reloadData];
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
    [self fetchPlayers];
    [self.tableView reloadData];
}

- (void)fetchPlayers
{
    if (!self.delegate.rosterId) {
        self.players = @[];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Loading Players"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [FFPlayer fetchPlayersForRoster:self.delegate.rosterId
                           position:self.delegate.positions[self.position]
                     removedBenched:self.delegate.autoRemovedBenched
                            session:self.session
                            success:
     ^(id successObj) {
         @strongify(self)
         self.players = successObj;
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                       withRowAnimation:UITableViewRowAnimationAutomatic];
         [alert hide];
     }
                            failure:
     ^(NSError *error) {
         @strongify(self)
         self.players = @[];
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                       withRowAnimation:UITableViewRowAnimationAutomatic];
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
        return 1;
    }
    return self.players.count;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        return 60.f;
    }
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        FFWideReceiverCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"
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
    FFTeamAddCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamAddCell"
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
        if (self.delegate) {
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

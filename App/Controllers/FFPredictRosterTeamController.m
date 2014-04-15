//
//  FFPredictRosterTeamController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictRosterTeamController.h"
#import "FFPredictRosterTeamTable.h"
#import "FFPredictRosterTeamCell.h"
#import "FFTeamTradeCell.h"
#import "FFRosterTableHeader.h"
#import "FFStyle.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFPathImageView.h"
#import "FFAlertView.h"
// model
#import "FFRosterPrediction.h"
#import "FFPlayer.h"

@interface FFPredictRosterTeamController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation FFPredictRosterTeamController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // table view
    self.tableView = [FFPredictRosterTeamTable.alloc initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.delegate.players.count;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.delegate.players.count > indexPath.row) {
        __block FFPlayer* player = self.delegate.players[indexPath.row];
        BOOL benched = player.benched.integerValue == 1;
        BOOL swapped = player.swappedPlayerName && player.swappedPlayerName.length > 0;
        if ([self.delegate.rosterState isEqualToString:@"finished"]) {
            FFPredictRosterTeamCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictRosterTeamCell"
                                                                            forIndexPath:indexPath];
            cell.titleLabel.text = player.team;
            cell.nameLabel.text = player.name;
            cell.costLabel.text = [FFStyle.priceFormatter
                                   stringFromNumber:@([player.sellPrice floatValue])];
            UIColor* avatarColor = swapped ? [FFStyle brightBlue] :
            ( benched ? [FFStyle brightOrange] : [FFStyle brightGreen] );
            cell.avatar.borderColor = avatarColor;
            cell.avatar.pathColor = avatarColor;
            [cell.avatar setImageWithURL: [NSURL URLWithString:player.headshotURL]
                        placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [cell.avatar draw];
            cell.benched.hidden = !benched;
            cell.swapped.hidden = !swapped;
            return cell;
        }
        FFTeamTradeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTradeCell"
                                                                forIndexPath:indexPath];
        cell.titleLabel.text = player.team;
        cell.nameLabel.text = player.name;
        cell.costLabel.text = [FFStyle.priceFormatter
                               stringFromNumber:@([player.purchasePrice floatValue])];
        CGFloat priceOdds = player.sellPrice.floatValue / player.purchasePrice.floatValue - 1.f;
        cell.centLabel.text = [NSString stringWithFormat:@"%.0f%%", priceOdds * 100.f];
        cell.centLabel.textColor = priceOdds > 0.f ? [FFStyle brightGreen] : [FFStyle brightRed];
        UIColor* avatarColor = swapped ? [FFStyle brightBlue] :
        ( benched ? [FFStyle brightOrange] : [FFStyle brightGreen] );
        cell.avatar.borderColor = avatarColor;
        cell.avatar.pathColor = avatarColor;
        [cell.avatar setImageWithURL: [NSURL URLWithString:player.headshotURL]
                    placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
         usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [cell.avatar draw];
        cell.benched.hidden = !benched;
        cell.swapped.hidden = !swapped;
        @weakify(self)
        [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           @strongify(self)
                           [self.parentViewController performSegueWithIdentifier:@"GotoPredictionsPT"
                                                                          sender:player]; // TODO: refactode it (?)
                       }];
        [cell.tradeButton setAction:kUIButtonBlockTouchUpInside
                          withBlock:^{
                              @strongify(self)
                              if (self.delegate) {
                                  [self.delegate removePlayer:player];
                              }
                          }];
        return cell;
    }
    return nil;
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
    FFRosterTableHeader* header = FFRosterTableHeader.new;
    header.titleLabel.text = NSLocalizedString(@"Your Team", nil);
    header.priceLabel.text = [[FFStyle priceFormatter] stringFromNumber:@(self.delegate.rosterSalary)];
    header.priceLabel.textColor = self.delegate.rosterSalary > 0.f
    ? [FFStyle brightGreen] : [FFStyle brightRed];
    return header;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

@end

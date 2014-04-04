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
#import "FFRosterTableHeader.h"
#import "FFStyle.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFPathImageView.h"
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
    return self.roster.players.count;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FFPredictRosterTeamCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictRosterTeamCell"
                                                                    forIndexPath:indexPath];
    if (self.roster.players.count > indexPath.row) {
        FFPlayer* player = self.roster.players[indexPath.row];
        cell.titleLabel.text = player.team;
        cell.nameLabel.text = player.name;
        //                cell.costLabel.text = [FFStyle.priceFormatter
        //                                       stringFromNumber:@([player.purchasePrice floatValue])];
#warning CHECK PRICE!
        cell.costLabel.text = [FFStyle.priceFormatter
                               stringFromNumber:@([player.sellPrice floatValue])];
        UIColor* avatarColor = player.benched.integerValue == 1
        ? [FFStyle brightOrange] : [FFStyle brightGreen];
        cell.avatar.borderColor = avatarColor;
        cell.avatar.pathColor = avatarColor;
        [cell.avatar setImageWithURL: [NSURL URLWithString:player.headshotURL]
                    placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
         usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [cell.avatar draw];
    }
    return cell;
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
    header.priceLabel.text = [[FFStyle priceFormatter] stringFromNumber:@(self.roster.remainingSalary.floatValue)];
    header.priceLabel.textColor = self.roster.remainingSalary.floatValue > 0.f
    ? [FFStyle brightGreen] : [FFStyle brightRed];
    return header;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

@end

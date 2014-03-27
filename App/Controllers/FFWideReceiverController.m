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
// model
#import "FFUser.h"

@interface FFWideReceiverController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) FUISegmentedControl* segments;

@end

@implementation FFWideReceiverController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[FFWideReceiverTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateHeader];
}

#pragma mark - public

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
    header.avatar.contentMode = UIViewContentModeScaleAspectFit;

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
    return 1;
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
        return cell;
    }
    FFTeamAddCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamAddCell"
                                                          forIndexPath:indexPath];
    cell.titleLabel.text = NSLocalizedString(@"Team: NYG PPG: 11.56", nil);
    cell.nameLabel.text = NSLocalizedString(@"Victor Cruz", nil);
    cell.costLabel.text = NSLocalizedString(@"$17287.0", nil);
    @weakify(self)
    [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                   withBlock:^{
                       @strongify(self)
                       [self.parentViewController performSegueWithIdentifier:@"GotoPT"
                                                                           sender:nil];
                   }];
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
        view.titleLabel.text = NSLocalizedString(@"Wide Receiver", nil);
        view.priceLabel.text = NSLocalizedString(@"$100000", nil);
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

@end

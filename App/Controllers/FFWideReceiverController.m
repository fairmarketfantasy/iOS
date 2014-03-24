//
//  FFWideReceiverController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverController.h"
#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import <FlatUIKit.h>
#import "FFRosterTableHeader.h"
#import "FFTeamAddCell.h"
#import "FFStyle.h"
#import <libextobjc/EXTScope.h>

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

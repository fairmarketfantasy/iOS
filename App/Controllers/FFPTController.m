//
//  FFPTController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPTController.h"
#import "FFPTTable.h"
#import "FFPTCell.h"
#import "FFPTHeader.h"

@interface FFPTController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) FFPTTable* tableView;

@end

@implementation FFPTController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView = [FFPTTable.alloc initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    FFPTHeader* header = FFPTHeader.new;
    header.title = @"Kobe Bryant";
    return header;
}

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: implement
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFPTCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PTCell"
                                                     forIndexPath:indexPath];
    cell.titleLabel.text = @"Points: 4";
    return cell;
}

@end

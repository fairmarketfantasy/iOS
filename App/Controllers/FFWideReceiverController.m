//
//  FFWideReceiverController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverController.h"
#import "FFWideReceiverTable.h"
#import <FlatUIKit.h>

@interface FFWideReceiverController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) FFWideReceiverTable* tableView;
@property(nonatomic) FUISegmentedControl* segments;

@end

@implementation FFWideReceiverController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // segment control
    self.segments = [[FUISegmentedControl alloc] initWithItems:[self gameTypes]];
    self.segments.frame = CGRectMake(0.f, 0.f, self.view.bounds.size.width, 44.f);
    [self.view addSubview:self.segments];
    // table view
    self.tableView = [[FFWideReceiverTable alloc] initWithFrame:self.view.bounds];
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
    return 0;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: imaplement
}

#pragma mark - private

// TODO: move to model
- (NSArray*)gameTypes
{
    return @[
             @"PG",
             @"SG",
             @"PF",
             @"C",
             @"G",
             @"F",
             @"UTIL"
             ];
}

@end

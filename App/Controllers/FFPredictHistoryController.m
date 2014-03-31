//
//  FFPredictHistoryController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryController.h"
//#import <FlatUIKit.h>
#import "FFNavigationBarItemView.h"
#import <LBActionSheet.h>
#import "FFLogo.h"
#import "FFPredictHistoryTable.h"
#import "FFPredictHistoryCell.h"
#import "FFPredictHeader.h"
#import "FFRosterTableHeader.h"

@interface FFPredictHistoryController () <LBActionSheetDelegate>

@property(nonatomic) LBActionSheet* typeSelector;
@property(nonatomic) UIButton* typeButton;
@property(nonatomic) FFPredictHistoryTable* tableView;

@end

@implementation FFPredictHistoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.typeSelector = [[LBActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"Roster", nil),
                         NSLocalizedString(@"Individual", nil), nil];
    // right bar item
    CGRect itemRect = CGRectMake(0.f, 0.f, 120.f, 27.f);
    FFNavigationBarItemView* rightItem = [[FFNavigationBarItemView alloc] initWithFrame:itemRect];
    self.typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.typeButton.frame = rightItem.bounds;
    [self.typeButton setImage:[UIImage imageNamed:@"show"]
                     forState:UIControlStateNormal];
    [self.typeButton setTitle:NSLocalizedString(@"Roster", nil)
                     forState:UIControlStateNormal];

    [self.typeButton setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                               forState:UIControlStateNormal];
    [self.typeButton setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                               forState:UIControlStateHighlighted];
    self.typeButton.titleLabel.font = [FFStyle blockFont:17.f];

    self.typeButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, self.typeButton.frame.size.width
                                                       - (self.typeButton.imageView.image.size.width + 15.f), 0.f, 0.f);
    self.typeButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                       3.f : 5.5f,
                                                       0.f, 0.f, self.typeButton.imageView.image.size.width  + 15.f);
    [self.typeButton addTarget:self
                        action:@selector(typeButton:)
              forControlEvents:UIControlEventTouchUpInside];
    self.typeButton.contentMode = UIViewContentModeScaleAspectFit;
    [rightItem addSubview:self.typeButton];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem* spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil
                                                                                   action:NULL];
        spaceItem.width = -16.f;
        self.navigationItem.rightBarButtonItems = @[
                                                    spaceItem,
                                                    [[UIBarButtonItem alloc] initWithCustomView:rightItem]
                                                    ];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItem];
    }
    // title
    self.navigationItem.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    // table view
    self.tableView = [[FFPredictHistoryTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - LBActionSheetDelegate

#pragma mark - button actions

- (void)typeButton:(UIButton*)button
{

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FFPredictHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictCell"
                                                                 forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 160.f;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

- (UIView*)tableView:(UITableView*)tableView
viewForHeaderInSection:(NSInteger)section
{
    FFRosterTableHeader* header = FFRosterTableHeader.new;
    header.titleLabel.text = NSLocalizedString(@"Individual predictions", nil);
    header.titleLabel.frame = CGRectMake(header.titleLabel.frame.origin.x,
                                         header.titleLabel.frame.origin.y,
                                         320.f - 2 * header.titleLabel.frame.origin.x,
                                         60.f);
    return header;
}

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

@end

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
#import "FFAlertView.h"
#import "FFAlertView.h"
#import "FFPathImageView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <FlatUIKit.h>
// model
#import "FFEvent.h"
#import "FFPlayer.h"
#import "FFStyle.h"

@interface FFPTController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) NSArray* events; // should contain FFEvent*
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
    UILabel* title = [UILabel.alloc initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    title.font = [FFStyle blockFont:19.f];
    title.textColor = [FFStyle white];
    title.text = @"WIN";
    title.textAlignment = NSTextAlignmentLeft;
    self.navigationItem.titleView = title;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchEvents];
    [self.tableView reloadData];
}

#pragma mark - private

- (void)fetchEvents
{
    if (!self.delegate.marketId || !self.player.statsId) {
        self.events = @[];
        [self.tableView reloadData];
        return;
    }
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [FFEvent fetchEventsForMarket:self.delegate.marketId
                           player:self.player
                          session:self.session
                          success:
     ^(id successObj) {
         @strongify(self)
         self.events = successObj;
         [self.tableView reloadData];
         [alert hide];
     }
                          failure:
     ^(NSError *error) {
         @strongify(self)
         self.events = @[];
         [self.tableView reloadData];
         [alert hide];
     }];
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
    header.title = self.player.name ? self.player.name : @"";
    header.team = self.player.team ? self.player.team : @"";
    [header.avatar setImageWithURL:[NSURL URLWithString:self.player.headshotURL]
                  placeholderImage:[UIImage imageNamed:@"rosterslotempty"]
       usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [header.avatar draw];
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
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFPTCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PTCell"
                                                     forIndexPath:indexPath];
    cell.segments.selectedSegmentIndex = UISegmentedControlNoSegment;
    if (self.events.count > indexPath.row) {
        FFEvent* event = self.events[indexPath.row];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@: %@", [event.name capitalizedString], event.value];
        cell.segments.userInteractionEnabled = YES;
        [cell.segments setEnabled:event.bidLess.integerValue == 0
                forSegmentAtIndex:0];
        [cell.segments setEnabled:event.bidMore.integerValue == 0
                forSegmentAtIndex:1];
        [cell.segments addTarget:self
                          action:@selector(onLessMore:)
                forControlEvents:UIControlEventValueChanged];
    } else {
        cell.titleLabel.text = @"";
        cell.segments.userInteractionEnabled = NO;
    }
    return cell;
}

#pragma mark - button actions

- (void)onLessMore:(FUISegmentedControl*)segments
{
    CGPoint segmentsPosition = [segments convertPoint:CGPointZero
                                               toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:segmentsPosition];
    if (!indexPath) {
        return;
    }
    if (self.events.count <= indexPath.row) {
        return;
    }
    __block FFEvent* event = self.events[indexPath.row];
    __block NSString* diff = segments.selectedSegmentIndex == 0 ? @"less" : @"more"; // TODO: move to model
    FFAlertView* confirmAlert = [FFAlertView.alloc initWithTitle:nil
                                                         message:[NSString stringWithFormat:@"Predict %@ %@ than %@ %@?",
                                                                  self.player.name, diff, event.value, event.name]
                                               cancelButtonTitle:@"Cancel"
                                                 okayButtonTitle:@"Submit"
                                                        autoHide:NO];
    [confirmAlert showInView:self.navigationController.view];
    @weakify(confirmAlert)
    @weakify(self)
    confirmAlert.onOkay = ^(id obj) {
        @strongify(confirmAlert)
        @strongify(self)
        __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Individual Predictions"
                                                               messsage:nil
                                                           loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
        [event individualPredictionsForMarket:self.delegate.marketId
                                       player:self.player.statsId
                                       roster:self.delegate.rosterId
                                         diff:diff
                                      success:
         ^(id successObj) {
             [alert hide];
             /* NBA-657
             [[[FFAlertView alloc] initWithTitle:nil
                                         message:successObj ? (NSString*)successObj
                                                : NSLocalizedString(@"Individual prediction submitted successfully!", nil)
                               cancelButtonTitle:nil
                                 okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                        autoHide:YES]
              showInView:self.navigationController.view];
              */
             [self fetchEvents];
             [self.tableView reloadData];
         }
                                      failure:
         ^(NSError *error) {
             [alert hide];
         }];
        [confirmAlert hide];
    };
    confirmAlert.onCancel = ^(id obj) { @strongify(confirmAlert) [confirmAlert hide]; };
    segments.selectedSegmentIndex = UISegmentedControlNoSegment;
}

@end

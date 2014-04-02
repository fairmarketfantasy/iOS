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
// model
#import "FFEvent.h"
#import "FFPlayer.h"

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
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Loading Events"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [FFEvent fetchEventsForMarket:self.delegate.marketId
                           player:self.player.statsId
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
         [[[FFAlertView alloc] initWithError:error
                                       title:nil
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
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
    if (self.events.count > indexPath.row) {
        FFEvent* event = self.events[indexPath.row];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ : %@", event.name, event.value];
    } else {
        cell.titleLabel.text = @"";
    }
    return cell;
}

@end

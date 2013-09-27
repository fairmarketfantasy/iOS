//
//  FFContestEntrantsViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/27/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFContestEntrantsViewController.h"
#import <SBData/SBDataObject.h>
#import "FFRoster.h"
#import "FFSessionViewController.h"


@interface FFContestEntrantsViewController ()
<UITableViewDataSource, UITableViewDelegate, SBDataObjectResultSetDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) SBDataObjectResultSet *rosters;

@end


@implementation FFContestEntrantsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *path = [NSString stringWithFormat:@"/rosters/in_contest/%@", _contest[@"id"]];
    SBModelQuery *query = [[[self.session queryBuilderForClass:[FFRoster class]]
                            property:@"contestId" isEqualTo:_contest[@"id"]]
                           query];
    _rosters = [FFRoster getBulkPath:path cacheQuery:query withSession:self.session authorized:YES];
    _rosters.clearsCollectionBeforeSaving = YES;
    _rosters.delegate = self;
    
    [_rosters refresh];
    
    [self.tableView reloadData];
}

- (void)resultSetDidReload:(SBDataObjectResultSet *)resultSet
{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rosters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[_rosters objectAtIndex:indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FFRoster *roster = [_rosters objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"GotoContest" sender:self context:roster];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

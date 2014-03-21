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

@interface FFPTController ()

@property(nonatomic) FFPTTable* tableView;

@end

@implementation FFPTController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [FFPTTable.alloc initWithFrame:self.view.bounds];
}

@end

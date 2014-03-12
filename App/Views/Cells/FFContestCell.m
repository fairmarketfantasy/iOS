//
//  FFContestCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFContestCell.h"
#import "FFContestView.h"

@implementation FFContestCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contestView = [[FFContestView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 150.f)];
        [self.contentView addSubview:self.contestView];
    }
    return self;
}

@end

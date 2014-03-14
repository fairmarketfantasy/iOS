//
//  FFUserBitCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFUserBitCell.h"
#import "FFUserBitView.h"

@implementation FFUserBitCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userBit = [[FFUserBitView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 122.f)];
        self.userBit.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.userBit];
    }
    return self;
}

- (void)setUserBit:(FFUserBitView *)userBit
{

}

@end

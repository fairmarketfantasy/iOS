//
//  FFEntrantsCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFEntrantsCell.h"

@implementation FFEntrantsCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView* disclosure = [[UIImageView alloc] initWithFrame:CGRectMake(295.f, 14.5f, 10.f, 15.f)];
        disclosure.image = [UIImage imageNamed:@"accessory_disclosure"];
        disclosure.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:disclosure];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 250.f, 44.f)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [FFStyle regularFont:17.f];
        self.label.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:self.label];
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                     self.contentView.frame.size.width, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:1.f];
    }
    return self;
}

@end

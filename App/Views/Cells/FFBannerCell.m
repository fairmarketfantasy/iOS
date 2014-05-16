//
//  FFBannerCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBannerCell.h"

@implementation FFBannerCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView* separator = [[UIView alloc] initWithFrame:
                                                CGRectMake(0.f,
                                                           CGRectGetMaxY(self.contentView.frame),
                                                           self.contentView.frame.size.width, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:1.f];
        [self.contentView addSubview:separator];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end

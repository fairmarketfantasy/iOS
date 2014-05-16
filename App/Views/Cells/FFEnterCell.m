//
//  FFEnterCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFEnterCell.h"
#import "FFStyle.h"

@implementation FFEnterCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.button = [FFStyle coloredButtonWithText:@""
                                               color:[FFStyle brightOrange]
                                         borderColor:[FFStyle brightOrange]];
        self.button.titleLabel.font = [FFStyle blockFont:19.f];
        self.button.frame = CGRectMake(15.f, 3.f, 290.f, 38.f);
        [self.contentView addSubview:self.button];
    }
    return self;
}

@end

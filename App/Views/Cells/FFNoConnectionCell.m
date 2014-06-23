//
//  FFNoConnectionCell.m
//  FMF Football
//
//  Created by Anton Chuev on 4/30/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNoConnectionCell.h"
#import "FFStyle.h"

@implementation FFNoConnectionCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.message = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 20.f)];
        self.message.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2 - 20.f);
        self.message.font = [FFStyle blockFont:20.f];
        self.message.textColor = [FFStyle lightGrey];
        self.message.backgroundColor = [UIColor clearColor];
        self.message.textAlignment = NSTextAlignmentCenter;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.message];
    }
    
    return self;
}

@end

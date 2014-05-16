//
//  FFNoConnectionCell.m
//  FMF Football
//
//  Created by Anton Chuev on 4/30/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNoConnectionCell.h"
#import "FFStyle.h"

@interface FFNoConnectionCell()



@end

@implementation FFNoConnectionCell

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.message = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 20.f)];
    self.message.center = self.center;
    self.message.font = [FFStyle blockFont:20.f];
    self.message.textColor = [FFStyle lightGrey];
    self.message.backgroundColor = [UIColor clearColor];
    self.message.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.message];
}

@end

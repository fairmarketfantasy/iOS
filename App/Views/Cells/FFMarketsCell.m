//
//  FFMarketsCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFMarketsCell.h"
#import "FFMarketSelector.h"

@implementation FFMarketsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(self.contentView.frame) - 1.f,
                                                                     300.f, 1.f)];
        separator.backgroundColor = [FFStyle tableViewSeparatorColor];
        separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        // market selector
        self.marketSelector = [[FFMarketSelector alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 60.f)];
        self.marketSelector.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.marketSelector];
    }
    return self;
}

@end

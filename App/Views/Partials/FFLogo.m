//
//  FFLogo.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFLogo.h"

@implementation FFLogo

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentLeft;

        NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc]
            initWithString:
                NSLocalizedString(@"Predict That",
                                  @"Session controller title")
                attributes:@{
                               NSFontAttributeName : [FFStyle blockFont:19.f],
                               NSForegroundColorAttributeName : [FFStyle white]
                           }];
        NSRange lastWord = [attributedTitle.string rangeOfString:@" "
                                                         options:NSBackwardsSearch];
        lastWord.location++;
        lastWord.length = attributedTitle.length - lastWord.location;

        [attributedTitle beginEditing];
        [attributedTitle addAttribute:NSFontAttributeName
                                value:[FFStyle italicBlockFont:19.f]
                                range:lastWord];
        [attributedTitle endEditing];

        self.attributedText = attributedTitle;
    }
    return self;
}

@end

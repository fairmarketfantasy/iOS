//
//  FFForgotPassword.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/18/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFForgotPassword.h"
#import "FFTextField.h"

@implementation FFForgotPassword

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:.94f
                                                 alpha:1.f];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(==145)]"
//                                                                     options:0
//                                                                     metrics:nil
//                                                                       views:NSDictionaryOfVariableBindings(self)]];

        // title

        UILabel* captionBalanceLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 10.f, 120.f, 30.f)];
        captionBalanceLabel.backgroundColor = [UIColor clearColor];
        captionBalanceLabel.textColor = [FFStyle darkGreyTextColor];
        captionBalanceLabel.font = [FFStyle blockFont:17.f];
        captionBalanceLabel.text = NSLocalizedString(@"Forgot Password", nil);
        [self addSubview:captionBalanceLabel];

        // separator

        UIView* separator = [UIView.alloc initWithFrame:CGRectMake(0.f, 44.f, self.bounds.size.width, 1.f)];
        separator.backgroundColor = [FFStyle lightGrey];
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separator];

        // subTitle

        UILabel* titleLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 55.f, 250.f, 20.f)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [FFStyle darkGreyTextColor];
        titleLabel.font = [FFStyle blockFont:14.f];
        titleLabel.text = NSLocalizedString(@"Enter your email address for instructions", nil);
        [self addSubview:titleLabel];

        // mail text field

        _mailField = FFTextField.new;
        self.mailField.layer.borderWidth = 1.f;
        self.mailField.frame = CGRectMake(10.f, 85.f, 240.f, 44.f);
        self.mailField.layer.borderColor = [FFStyle greyBorder].CGColor;
        self.mailField.backgroundColor = [FFStyle white];
        self.mailField.placeholder = NSLocalizedString(@"email", nil);
        self.mailField.returnKeyType = UIReturnKeySend;
        self.mailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.mailField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.mailField.keyboardType = UIKeyboardTypeEmailAddress;
        [self addSubview:self.mailField];
    }
    return self;
}

@end

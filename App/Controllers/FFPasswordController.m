//
//  FFPasswordController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPasswordController.h"
#import <QuartzCore/QuartzCore.h>
#import "FFUser.h"
#import "FFAlertView.h"

@interface FFPasswordController () <UITextFieldDelegate>

@end

@implementation FFPasswordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // current password
    _currentPassword = UITextField.new;
    self.currentPassword.layer.borderWidth = 1.f;
    self.currentPassword.frame = CGRectMake(15.f, 30.f, 290.f, 44.f);
    self.currentPassword.font = [FFStyle regularFont:17.f];
    self.currentPassword.textColor = [FFStyle darkGreyTextColor];
    self.currentPassword.layer.borderColor = [FFStyle greyBorder].CGColor;
    self.currentPassword.backgroundColor = [FFStyle white];
    self.currentPassword.delegate = self;
    self.currentPassword.placeholder = NSLocalizedString(@" Current Password", nil);
    self.currentPassword.returnKeyType = UIReturnKeyNext;
    self.currentPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.currentPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.currentPassword.keyboardType = UIKeyboardTypeASCIICapable;
    self.currentPassword.secureTextEntry = YES;
    [self.view addSubview:self.currentPassword];
    // new password
    _theNewPassword = UITextField.new;
    self.theNewPassword.layer.borderWidth = 1.f;
    self.theNewPassword.frame = CGRectMake(15.f, 89.f, 290.f, 44.f);
    self.theNewPassword.font = [FFStyle regularFont:17.f];
    self.theNewPassword.textColor = [FFStyle darkGreyTextColor];
    self.theNewPassword.layer.borderColor = [FFStyle greyBorder].CGColor;
    self.theNewPassword.backgroundColor = [FFStyle white];
    self.theNewPassword.delegate = self;
    self.theNewPassword.placeholder = NSLocalizedString(@" New Password", nil);
    self.theNewPassword.returnKeyType = UIReturnKeyNext;
    self.theNewPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.theNewPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.theNewPassword.keyboardType = UIKeyboardTypeASCIICapable;
    self.theNewPassword.secureTextEntry = YES;
    [self.view addSubview:self.theNewPassword];
    // confirm password
    _confirmPassword = UITextField.new;
    self.confirmPassword.layer.borderWidth = 1.f;
    self.confirmPassword.frame = CGRectMake(15.f, 148.f, 290.f, 44.f);
    self.confirmPassword.font = [FFStyle regularFont:17.f];
    self.confirmPassword.textColor = [FFStyle darkGreyTextColor];
    self.confirmPassword.layer.borderColor = [FFStyle greyBorder].CGColor;
    self.confirmPassword.backgroundColor = [FFStyle white];
    self.confirmPassword.delegate = self;
    self.confirmPassword.placeholder = NSLocalizedString(@" Confirm Password", nil);
    self.confirmPassword.returnKeyType = UIReturnKeyDone;
    self.confirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.confirmPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.confirmPassword.keyboardType = UIKeyboardTypeASCIICapable;
    self.confirmPassword.secureTextEntry = YES;
    [self.view addSubview:self.confirmPassword];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.currentPassword becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentPassword endEditing:YES];
    [self.theNewPassword endEditing:YES];
    [self.confirmPassword endEditing:YES];
    if (!self.delegate) {
        return;
    }
    if (self.currentPassword.text.length < 6) {
        [[[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Password will not changed", nil)
                                    message:NSLocalizedString(@"Current password shold be at least 6 characters long", nil)
                          cancelButtonTitle:nil
                            okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                   autoHide:YES] showInView:self.delegate.view];
        return;
    }
    if (self.theNewPassword.text.length < 6) {
        [[[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Password will not changed", nil)
                                    message:NSLocalizedString(@"New password shold be at least 6 characters long", nil)
                          cancelButtonTitle:nil
                            okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                   autoHide:YES] showInView:self.delegate.view];
        return;
    }
    if (![self.theNewPassword.text isEqual:self.confirmPassword.text]) {
        [[[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Password will not changed", nil)
                                    message:NSLocalizedString(@"Your confirmation not match", nil)
                          cancelButtonTitle:nil
                            okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                   autoHide:YES] showInView:self.delegate.view];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(updatePassword:)]) {
        [self.delegate updatePassword:self.confirmPassword.text
                              current:self.currentPassword.text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == self.currentPassword) {
        [self.theNewPassword becomeFirstResponder];
        return NO;
    }
    if (textField == self.theNewPassword) {
        [self.confirmPassword becomeFirstResponder];
        return NO;
    }
    if (textField == self.confirmPassword) {
        [textField endEditing:YES];
    }
    return YES;
}

@end

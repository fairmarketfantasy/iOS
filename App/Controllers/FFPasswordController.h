//
//  FFPasswordController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@protocol FFPasswordControllerDelegate <NSObject>

@optional
- (void)updatePassword:(NSString*)password
               current:(NSString*)current;

@end

@interface FFPasswordController : FFBaseViewController

@property(nonatomic, readonly) UITextField* currentPassword;
@property(nonatomic, readonly) UITextField* theNewPassword;
@property(nonatomic, readonly) UITextField* confirmPassword;
@property(nonatomic, weak) UINavigationController<FFPasswordControllerDelegate>* delegate;

@end

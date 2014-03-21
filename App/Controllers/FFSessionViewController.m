//
//  FFSplashViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/12/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFSessionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FFTextField.h"
#import "FFAlertView.h"
#import "UIView+FindFirstResponder.h"
#import <SBData/SBData.h>
#import "FFUser.h"
#import "FFSession.h"
#import "FFWebViewController.h"
#import "FFNavigationBarItemView.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FFSessionViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property(nonatomic) UIView* signInView;
@property(nonatomic) UIButton* signInFacebookButton;
@property(nonatomic) UIButton* signInButton;
@property(nonatomic) UIButton* signInHeaderButton;
@property(nonatomic) UITextField* usernameSigninField;
@property(nonatomic) UITextField* passwordSigninField;
@property(nonatomic) UIGestureRecognizer* dismissKeyboardRecognizer;
@property(nonatomic) CGFloat keyboardHeight;
@property(nonatomic) BOOL keyboardIsShowing;
@property(nonatomic) FFTickerMaximizedDrawerViewController* signInTicker;
@property(nonatomic) UIView* container;

- (void)setupSignInView;
- (void)signIn:(id)sender;
- (void)signInFacebook:(id)sender;
- (void)forgotPassword:(id)sender;
- (void)dismissKeyboard:(id)sender;

@end

@implementation FFSessionViewController

- (id)initWithNibName:(NSString*)nibNameOrNil
               bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.session = [FFSession lastUsedSessionWithUserClass:[FFUser class]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.session = [FFSession lastUsedSessionWithUserClass:[FFUser class]];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signInView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.view.frame.size.height)];
    [self setupSignInView];

    [self.view addSubview:self.signInView];
    [_signInTicker viewDidAppear:NO];

    _dismissKeyboardRecognizer = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard:)];
    _dismissKeyboardRecognizer.delegate = self;
    [self.view addGestureRecognizer:_dismissKeyboardRecognizer];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotLogout:)
                                                 name:SBLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotLogout:)
                                                 name:SBLoginDidBecomeInvalidNotification
                                               object:nil];
    if (!self.session) {
        [self.tickerDataSource refresh];
        return;
    }
    [self pollUser];
    [self.session syncPushToken];
    [self performSegueWithIdentifier:@"GoImmediatelyToHome"
                              sender:nil];
}

- (id)ticker
{
    FFTickerMaximizedDrawerViewController* maximizedTicker = [FFTickerMaximizedDrawerViewController new];
    maximizedTicker.view.backgroundColor = [FFStyle darkGreen];
    maximizedTicker.session = self.session;
    [self.tickerDataSource addDelegate:maximizedTicker];
    return maximizedTicker;
}

- (void)gotLogout:(NSNotification*)note
{
    NSLog(@"Got login/logout notification: %@", note);
    self.session = nil;

    [self dismissViewControllerAnimated:YES
                             completion:^{
        NSLog(@"done dismissing view controllers");
                             }];
}

// TODO: move into separate VIEW
- (void)setupSignInView
{
    // background
    UIImageView* backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginbg.png"]];
    backgroundView.contentMode = UIViewContentModeTop;
    backgroundView.frame = self.signInView.bounds;
    [self.signInView addSubview:backgroundView];

    self.container = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.view.frame.size.height)];
    self.container.backgroundColor = [UIColor clearColor];

    [self.signInView addSubview:self.container];

    UILabel* signInLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 90.f, 290.f, 60.f)];
    signInLabel.font = [FFStyle lightFont:30.f];
    signInLabel.text = NSLocalizedString(@"Sign In", nil);
    signInLabel.backgroundColor = [UIColor clearColor];
    signInLabel.textColor = [FFStyle white];
    [self.container addSubview:signInLabel];

    // mail text field
    UITextField* mailField = [FFTextField new];
    mailField.layer.borderWidth = 1.f;
    mailField.frame = CGRectMake(15.f, 155.f, 290.f, 44.f);
    mailField.layer.borderColor = [FFStyle greyBorder].CGColor;
    mailField.backgroundColor = [FFStyle white];
    mailField.delegate = self;
    mailField.placeholder = NSLocalizedString(@"email", nil);
    mailField.returnKeyType = UIReturnKeyNext;
    mailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    mailField.autocorrectionType = UITextAutocorrectionTypeNo;
    mailField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.container addSubview:mailField];
    self.usernameSigninField = mailField;

    // password text field
    UITextField* passwordField = [FFTextField new];
    passwordField.layer.borderWidth = 1.f;
    passwordField.layer.borderColor = [FFStyle greyBorder].CGColor;
    passwordField.backgroundColor = [FFStyle white];
    passwordField.delegate = self;
    passwordField.frame = CGRectMake(15.f, 210.f, 290.f, 44.f);
    passwordField.secureTextEntry = YES;
    passwordField.placeholder = NSLocalizedString(@"password", nil);
    passwordField.returnKeyType = UIReturnKeyGo;
    [self.container addSubview:passwordField];
    self.passwordSigninField = passwordField;

    // sign in button
    UIButton* signInButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"Sign In", nil)
                                                      color:[FFStyle brightGreen]
                                                borderColor:[FFStyle white]];
    signInButton.frame = CGRectMake(15.f, 265.f, 290.f, 38.f);
    signInButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                    3.f : 5.5f,
                                                    0.f, 0.f, 0.f);
    [signInButton addTarget:self
                     action:@selector(signIn:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:signInButton];
    self.signInButton = signInButton;

    // sign in via FaceBook button
    UIButton* fbSignIn = [FFStyle coloredButtonWithText:NSLocalizedString(@"Sign in with Facebook",
                                                                          @"FB sign in button")
                                                  color:[FFStyle brightBlue]
                                            borderColor:[FFStyle white]];
    fbSignIn.frame = CGRectMake(15.f, 315.f, 290.f, 38.f);
    fbSignIn.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                3.f : 5.5f,
                                                0.f, 0.f, 0.f);
    [fbSignIn addTarget:self
                  action:@selector(signInFacebook:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:fbSignIn];
    self.signInFacebookButton = fbSignIn;

    // forgot password button
    UIButton* forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotButton setTitle:NSLocalizedString(@"Forgot Your Password?", nil)
                  forState:UIControlStateNormal];
    forgotButton.frame = CGRectMake(15.f, 365.f, 290.f, 50.f);
    forgotButton.titleLabel.font = [FFStyle regularFont:14.f];
    forgotButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [forgotButton setTitleColor:[FFStyle lightGrey]
                       forState:UIControlStateNormal];
    [forgotButton setTitleColor:[FFStyle darkerColorForColor:[FFStyle white]]
                       forState:UIControlStateHighlighted];
    [forgotButton addTarget:self
                     action:@selector(forgotPassword:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:forgotButton];

    if (IS_SMALL_DEVICE) {
        self.container.frame = CGRectOffset(self.container.frame, 0.f, -40.f);
        signInLabel.font = [FFStyle lightFont:24];
        signInLabel.frame = CGRectOffset(signInLabel.frame, 0.f, 8.f);
    }

    _signInTicker = [self ticker];
    _signInTicker.view.frame = CGRectMake(0.f, CGRectGetMaxY(self.signInView.frame) - 95.f, 320.f, 95.f);
    [_signInTicker viewWillAppear:NO];
    [self.signInView addSubview:_signInTicker.view];
}

#pragma mark -
// IBACTIONS -----------------------------------------------------------------------------------------------------------

- (void)signIn:(id)sender
{
#warning for TESTING only >>>
    [self performSegueWithIdentifier:@"GotoHome"
                              sender:nil];
#warning for TESTING only <<<
    // get/compile the regex we'll be using
    __strong static NSRegularExpression* regex = nil; // ???: rewrite
    if (regex == nil) {
        NSError* error = nil;
        NSString* emailRe = FF_EMAIL_REGEX;
        regex = [NSRegularExpression regularExpressionWithPattern:emailRe
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        if (error) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Could not compile regex"
                                         userInfo:NSDictionaryOfVariableBindings(emailRe)];
        }
    }

    NSString* errorTitle = nil;

    if (!self.usernameSigninField.text.length) {
        errorTitle = NSLocalizedString(@"Please provide your email address", nil);
    } else {
        NSString* email = self.usernameSigninField.text;
        NSTextCheckingResult* result = [regex firstMatchInString:email
                                                         options:0
                                                           range:NSMakeRange(0, email.length)];
        if (!result.range.length) {
            errorTitle = NSLocalizedString(@"Please provide a valid email address", nil);
        } else if (self.passwordSigninField.text.length < 6) {
            errorTitle = NSLocalizedString(@"Please provide a password at least 6 characters long", nil);
        }
    }

    if (errorTitle) {
        [[[FFAlertView alloc] initWithTitle:nil
                                    message:errorTitle
                          cancelButtonTitle:nil
                            okayButtonTitle:NSLocalizedString(@"Okay", nil)
                                   autoHide:YES] showInView:self.view];
        return;
    }

    FFAlertView* progressAlert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Finding Account", @"creating account")
                                                           messsage:NSLocalizedString(@"In a few short moments you'll be on your way!",
                                                                                      @"on sign in, tells the user they will be signed in soon")
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [progressAlert showInView:self.view];
    FFSession* sesh = [FFSession sessionWithEmailAddress:self.usernameSigninField.text
                                               userClass:[FFUser class]];
    [sesh loginWithEmail:self.usernameSigninField.text password:self.passwordSigninField.text success:^(id user)
    {
        [progressAlert hide];
        [[self.view findFirstResponder] resignFirstResponder];
        self.session = sesh;
        [self pollUser];
        [self.session syncPushToken];
        [FFSession setLastUsedSession:sesh];
        [self performSegueWithIdentifier:@"GotoHome"
                                  sender:nil];
        NSLog(@"successful login %@", user);
    }
failure:
    ^(NSError * err)
    {
        [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"SignInError: %@", err]
                              level:@"error"];
        [progressAlert hide];
        [[[FFAlertView alloc] initWithError:err
                                      title:nil
                          cancelButtonTitle:nil
                            okayButtonTitle:NSLocalizedString(@"Dismiss", @"dismiss error dialog")
                                   autoHide:YES]
            showInView:self.view];
    }];
}

- (void)forgotPassword:(id)sender
{
    [self performSegueWithIdentifier:@"GotoForgotPassword"
                              sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GotoForgotPassword"]) {
        NSString* baseUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:SBApiBaseURLKey];
        FFWebViewController* vc = [segue.destinationViewController viewControllers][0];
        vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingString:@"/pages/mobile/forgot_password"]];
    }
}

#pragma mark - Facebook stuff

- (void)signInFacebook:(id)sender
{
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"] allowLoginUI:YES completionHandler:
     ^(FBSession *session, FBSessionState status, NSError *error)
    {
        [self fbSessionStateChanged:session
                              state:status
                              error:error];
    }];
}

- (void)fbSessionStateChanged:(FBSession*)session
                        state:(FBSessionState)state
                        error:(NSError*)error
{
    switch (state) {
    case FBSessionStateOpen:
        // pass the token back to the server
        [self loginFbToken:session.accessTokenData.accessToken];
        break;
    case FBSessionStateClosed:
    case FBSessionStateClosedLoginFailed:
        [FBSession.activeSession closeAndClearTokenInformation];
        break;
    default:
        break;
    }
    if (!error) {
        return;
    }
    [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"FBSessionError: %@", error]
                          level:@"error"];
    [[[UIAlertView alloc]
             initWithTitle:@"Error"
                   message:error.localizedDescription
                  delegate:nil
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil] show];
}

- (void)loginFbToken:(NSString*)accessToken
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Creating Account", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.view];

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        if (error) {
            [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"FBGetMeError: %@", error]
                                  level:@"error"];
            [alert hide];
            FFAlertView* ealert = [[FFAlertView alloc] initWithError:error
                                                               title:nil
                                                   cancelButtonTitle:nil
                                                     okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                            autoHide:YES];
            [ealert showInView:self.view];
            return;
        }
        if (!result[@"email"] || [result[@"email"] isEqual:[NSNull null]]) {
            [alert hide];
            [[Ubertesters shared] UTLog:@"FBNoEmailError: There was no email for a provided account"
                                  level:@"error"];
            FFAlertView* ealert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                             message:NSLocalizedString(@"The provided Facebook account does not have a verified email address associated with it. It could be a new account, to which Facebook does not yet give us access to the email. For now, you'll have to use a regular username and password to create an account.", nil)
                                                   cancelButtonTitle:nil
                                                     okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                            autoHide:YES];
            [ealert showInView:self.view];
            return;
        }
        FFSession* sesh = [FFSession sessionWithEmailAddress:result[@"email"]
                                                   userClass:[FFUser class]];
        [sesh registerAndLoginUsingFBAccessToken:accessToken fbUid:[result[@"id"] description] success:^(id successObj)
        {
            [alert hide];

            [[self.view findFirstResponder] resignFirstResponder];
            [FFSession setLastUsedSession:sesh];
            self.session = sesh;
            [self pollUser];
            [self.session syncPushToken];
            [self performSegueWithIdentifier:@"GotoHome"
                                      sender:nil];
        }
    failure:
        ^(NSError * error)
        {
            [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"FBRegisterOAuthError: %@", error]
                                  level:@"error"];
            [alert hide];
            FFAlertView* ealert = [[FFAlertView alloc] initWithError:error
                                                               title:nil
                                                   cancelButtonTitle:nil
                                                     okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                            autoHide:YES];
            [ealert showInView:self.view];
        }];
    }];
}

#pragma mark -
// GESTURE RECOGNIZER --------------------------------------------------------------------------------------------------

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
       shouldReceiveTouch:(UITouch*)touch
{
    return YES;
}

- (void)dismissKeyboard:(id)sender
{
    [[self.view findFirstResponder] resignFirstResponder];
}

#pragma mark -
// TEXT FIELDS ---------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == self.usernameSigninField) {
        [self.passwordSigninField becomeFirstResponder];
        return NO;
    }
    if (textField == self.passwordSigninField) {
        [self signIn:nil];
    }
    [textField endEditing:YES];
    return YES;
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification*)note
{
    CGRect keyboardBounds;
    NSValue* aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    [aValue getValue:&keyboardBounds];

    _keyboardHeight = keyboardBounds.size.height;

    if (_keyboardIsShowing) {
        return;
    }
    _keyboardIsShowing = YES;

    CGRect viewFrame = CGRectOffset(self.container.frame, 0.f, IS_SMALL_DEVICE ? -50.f : -80.f);

    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:^{
                         self.container.frame = viewFrame;
                         self.navigationController.navigationBarHidden = YES;
                     }];
}

- (void)keyboardWillHide:(NSNotification*)note
{
    CGRect keyboardBounds;
    NSValue* aValue = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    [aValue getValue:&keyboardBounds];

    _keyboardHeight = keyboardBounds.size.height;

    if (!_keyboardIsShowing) {
        return;
    }
    _keyboardIsShowing = NO;

    CGRect viewFrame = CGRectOffset(self.container.frame, 0.f, IS_SMALL_DEVICE ? 50.f : 80.f);

    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:^{
                         self.navigationController.navigationBarHidden = NO;
                         self.container.frame = viewFrame;
                     }];
}

#pragma mark -
// session controller stuff --------------------------------------------------------------------------------------------

- (NSInteger)balanceViewGetBalance:(FFBalanceButton*)view
{
    FFUser* user = (FFUser*)self.session.user;
    return [user.tokenBalance integerValue];
}

- (void)pollUser
{
    [self.session syncUserSuccess:^(id successObj)
    {
        FFUser* user = successObj;

        [[NSNotificationCenter defaultCenter] postNotificationName:FFSessionDidUpdateUserNotification
                                                            object:nil
                                                          userInfo:@{
                                                                       FFUserKey : user
                                                                   }];

        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self pollUser];
        });
    }
failure:
    ^(NSError * error)
    {
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self pollUser];
        });
    }];
}

- (void)updateUserNow
{
    [self.session syncUserSuccess:^(id successObj)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:FFSessionDidUpdateUserNotification
                                                            object:nil
                                                          userInfo:@{
                                                                       FFUserKey : successObj
                                                                   }];
    }
failure:
    ^(NSError * error)
    {
        NSLog(@"failed to get user");
    }];
}

@end

#pragma mark -

@implementation UIViewController (FFSessionController)

- (FFSessionViewController*)sessionController
{
    return [self lookForSessionController:self];
}

- (FFSessionViewController*)lookForSessionController:(UIViewController*)vc
{
    if ([vc isKindOfClass:[FFSessionViewController class]]) {
        return (FFSessionViewController*)vc;
    }
    if (vc.parentViewController) {
        id ret = [self lookForSessionController:vc.parentViewController];
        if (ret) {
            return ret;
        }
    }
    if (vc.presentingViewController) {
        id ret = [self lookForSessionController:vc.presentingViewController];
        if (ret) {
            return ret;
        }
    }
    UINavigationController* navVc = nil;
    if (vc.navigationController) {
        navVc = vc.navigationController;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        navVc = (UINavigationController*)vc;
    }
    if (navVc) {
        for (UIViewController* nvc in navVc.viewControllers) {
            id ret = [self lookForSessionController:nvc];
            if (ret) {
                return ret;
            }
        }
    }
    return nil;
}

- (FFSession*)session
{
    return self.sessionController.session;
}

@end

//
//  FFSplashViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/12/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFSessionViewController.h"
#import "FFTextField.h"
#import "FFAlertView.h"
#import "FFUser.h"
#import "FFSession.h"
#import "FFWebViewController.h"
#import "FFNavigationBarItemView.h"
#import "FFForgotPassword.h"
#import "Reachability.h"
#import "UIView+FindFirstResponder.h"
#import <FacebookSDK/FacebookSDK.h>
#import <SBData/SBData.h>
#import <QuartzCore/QuartzCore.h>

#define FORGOT_PASS_ALERT_TAG 0xC005

@interface FFSessionViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property(nonatomic) UIView* signInView;
@property(nonatomic) UIImageView *backgroundView;
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
@property(nonatomic) UITextField* forgotPasswordField;
@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) NSUInteger indexShowingSport;
@property(nonatomic, strong) NSArray *availableSports;
@property(nonatomic, strong) NSTimer *timer;

- (void)setupSignInView;
- (void)signIn:(id)sender;
- (void)signInFacebook:(id)sender;
- (void)forgotPassword:(id)sender;
- (void)dismissKeyboard:(id)sender;

@end

@implementation FFSessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.session = [FFSession lastUsedSessionWithUserClass:[FFUser class]];
    self.availableSports = @[@"NBA", @"MLB"];
    self.indexShowingSport = 0;
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
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		NSLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
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
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotLogout:)
                                                 name:SBLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotLogout:)
                                                 name:SBLoginDidBecomeInvalidNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    [self createTimer];
    
    if (!self.session) {
        [self.tickerDataSource refresh];
        return;
    }

    [self.session pollUser];
    [self.session syncPushToken];
    [self performSegueWithIdentifier:@"GoImmediatelyToHome"
                              sender:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SBLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SBLoginDidBecomeInvalidNotification object:nil];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [super viewDidDisappear:animated];
}

#pragma mark -

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
    }
}

#pragma mark -

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

#pragma mark

- (void)changeBackgroundImage:(NSTimer *)timer
{
    NSString *smallImageName = nil;
    NSString *bigImageName = nil;
    
    if ([self.availableSports[self.indexShowingSport] isEqualToString:@"MLB"]) {
        smallImageName = @"loginmlb";
        bigImageName = @"loginmlb-586h";
    } else {
        smallImageName = @"loginbg";
        bigImageName = @"loginbg-586h";
    }
    
    if (self.indexShowingSport == self.availableSports.count - 1)
        self.indexShowingSport = 0;
    else
        self.indexShowingSport++;
    
    NSString *imageName = IS_SMALL_DEVICE ? smallImageName : bigImageName;
    
    [UIView transitionWithView:self.backgroundView
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.image = [UIImage imageNamed:imageName];
                    } completion:nil];
}

- (void)createTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                  target:self
                                                selector:@selector(changeBackgroundImage:)
                                                userInfo:nil
                                                 repeats:YES];
    [self.timer fire];
}

#pragma mark

// TODO: move into separate VIEW
- (void)setupSignInView
{
    // background
    self.backgroundView = [UIImageView new];
//    backgroundView.contentMode = UIViewContentModeTop;
    self.backgroundView.frame = self.signInView.bounds;
    [self.signInView addSubview:self.backgroundView];

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
    UITextField* mailField = FFTextField.new;
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
//    [self.signInView addSubview:_signInTicker.view];
}

#pragma mark -
// IBACTIONS -----------------------------------------------------------------------------------------------------------

- (void)signIn:(id)sender
{
    // get/compile the regex we'll be using
    __strong static NSRegularExpression* regex = nil;
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

    if (self.networkStatus == NotReachable) {
        [self showNoInternetConnectionAlert];
        
        return;
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
                            okayButtonTitle:NSLocalizedString(@"Ok", nil)
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
        [self.session pollUser];
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
                          withLevel:UTLogLevelError];
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
    if (self.networkStatus == NotReachable) {
        [self showNoInternetConnectionAlert];
        
        return;
    }
    
    FFForgotPassword *view = [[FFForgotPassword alloc] initWithFrame:CGRectMake(0.f, 0.f, 260.f, 145.f)];
    self.forgotPasswordField = view.mailField;
    view.mailField.delegate = self;
    
    //TODO: TEMPORARY solution, need better way
    FFAlertView* forgotAlert = [[FFAlertView alloc] initWithTitle:nil
                                                          message:nil
                                                       customView:view
                                                cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                                  okayButtonTitle:NSLocalizedString(@"Send Instructions", nil)
                                                         autoHide:NO
                                                 usingAutolayouts:NO];
    
    @weakify(self)
    @weakify(forgotAlert)
    forgotAlert.onOkay = ^(id obj) {
        @strongify(forgotAlert)
        @strongify(self)
        [self sendForgotPasswordWithCompletion:^(BOOL shouldHideAlert) {
            if (shouldHideAlert) {
                [forgotAlert hide];
            } else if (_keyboardIsShowing == YES && shouldHideAlert == NO) {
                FFAlertView *forgotAlert = (FFAlertView *)[self.view viewWithTag:FORGOT_PASS_ALERT_TAG];
                CGFloat inset = IS_SMALL_DEVICE ? 90.f : 50.f;
                [forgotAlert setYInset:inset animated:YES];
            }
        }];
    };
    forgotAlert.onCancel = ^(id obj) {
        @strongify(forgotAlert)
        @strongify(self)
        [forgotAlert hide];
        self.forgotPasswordField = nil;
    };
    
    forgotAlert.tag = FORGOT_PASS_ALERT_TAG;
    [forgotAlert showInView:self.view];
}

- (void)sendForgotPasswordWithCompletion:(void(^)(BOOL shouldHideAlert))block
{
    __strong static NSRegularExpression* regex = nil;
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
    
    __block NSString *email = self.forgotPasswordField.text;
    NSTextCheckingResult* result = [regex firstMatchInString:email
                                                     options:0
                                                       range:NSMakeRange(0, email.length)];
    if (!result.range.length) {
        errorTitle = NSLocalizedString(@"Please provide a valid email address", nil);
        
        [[[FFAlertView alloc] initWithTitle:nil
                                    message:errorTitle
                          cancelButtonTitle:nil
                            okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                   autoHide:YES] showInView:self.navigationController.view];
        if (block) {
            block(NO);
        }
        
        return;
    }
    
    if (block) {
        block(YES);
    }
    
    FFSession* tempSession = [FFSession anonymousSession];
    @weakify(self)
    [tempSession anonymousJSONRequestWithMethod: @"POST"
                                           path: @"/users/reset_password" // TODO: should me moved to FFUser
                                     parameters: @{ @"email" : email }
                                        success: ^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON)
     {}
                                        failure:
     ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
     {
         @strongify(self)
         [[[FFAlertView alloc] initWithError:error
                                       title:error ? nil : @"Unexpected Error"
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
     }];
    self.forgotPasswordField = nil;
}

#pragma mark - Facebook stuff

- (void)signInFacebook:(id)sender
{
    if (self.networkStatus == NotReachable) {
        [self showNoInternetConnectionAlert];
        
        return;
    }
    
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:
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
            break;
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
        break;
    }
    if (!error || error.code == 2) {
        return;
    }
    [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"FBSessionError: %@", error]
                      withLevel:UTLogLevelError];
    [[[UIAlertView alloc]
             initWithTitle:@"Error"
                   message:error.localizedDescription
                  delegate:nil
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil] show];
}

- (void)loginFbToken:(NSString*)accessToken
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:nil/*NSLocalizedString(@"Creating Account", nil)*/
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.view];

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    {
        if (error) {
            [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"FBGetMeError: %@", error]
                              withLevel:UTLogLevelError];
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
                              withLevel:UTLogLevelError];
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
            [self.session pollUser];
            [self.session syncPushToken];
            [self performSegueWithIdentifier:@"GotoHome"
                                      sender:nil];
        }
    failure:
        ^(NSError * error)
        {
            [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"FBRegisterOAuthError: %@", error]
                              withLevel:UTLogLevelError];
            [alert hide];
            
            //TODO:should replace
            NSString *localizedDescription = error.userInfo[@"NSLocalizedDescription"];
            
            FFAlertView *alert = nil;
            if ([localizedDescription rangeOfString:@"500"].location != NSNotFound) {
                alert = [[FFAlertView alloc] initWithTitle:nil
                                                   message:NSLocalizedString(@"Facebook sign ining is unavailable now", nil)
                                         cancelButtonTitle:nil
                                           okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  autoHide:YES];
            } else {
                alert = [[FFAlertView alloc] initWithError:error
                                                     title:nil
                                         cancelButtonTitle:nil
                                           okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  autoHide:YES];
            }
            
            [alert showInView:self.view];
        }];
    }];
}

#pragma mark

- (void)showNoInternetConnectionAlert
{
    FFAlertView *alert = [FFAlertView noInternetConnectionAlert];
    [alert showInView:self.view];
}

#pragma mark - gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
       shouldReceiveTouch:(UITouch*)touch
{
    return YES;
}

- (void)dismissKeyboard:(id)sender
{
    if (_keyboardIsShowing) {
        [[self.view findFirstResponder] resignFirstResponder];
        FFAlertView *forgotAlert = (FFAlertView *)[self.view viewWithTag:FORGOT_PASS_ALERT_TAG];
        CGFloat inset = IS_SMALL_DEVICE ? 90.f : 50.f;
        [forgotAlert setYInset:inset animated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    if (textField == self.forgotPasswordField) {
        FFAlertView *forgotAlert = (FFAlertView *)[self.view viewWithTag:FORGOT_PASS_ALERT_TAG];
        CGFloat inset = IS_SMALL_DEVICE ? -90.f : -50.f;
        [forgotAlert setYInset:inset animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField == self.usernameSigninField) {
        [self.passwordSigninField becomeFirstResponder];
        return NO;
    }
    if (textField == self.passwordSigninField) {
        [self signIn:textField];
    }
    if (textField == self.forgotPasswordField) {
        [self sendForgotPasswordWithCompletion:^(BOOL shouldHide) {
            if (shouldHide) {
                FFAlertView *forgotAlert = (FFAlertView *)[self.view viewWithTag:FORGOT_PASS_ALERT_TAG];
                [forgotAlert hide];
            }
        }];
    }
    
    [textField endEditing:YES];
    return YES;
}

#pragma mark - notifications callback

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

    CGRect viewFrame = CGRectOffset(self.container.frame, 0.f, IS_SMALL_DEVICE ? 50.f : 80.f);

    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:^{
                         self.navigationController.navigationBarHidden = NO;
                         self.container.frame = viewFrame;
                     }];
}

- (void)keyboardDidHide:(NSNotification *)note
{
    _keyboardIsShowing = NO;
}

@end

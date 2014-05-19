//
//  FFSession.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/19/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFSession.h"
#import <AFNetworking/AFHTTPClient.h>
#import "FFMarket.h"
#import "FFGame.h"
#import "FFContestType.h"
#import "FFRoster.h"

@interface SBSession (private)

@property (nonatomic) SBUser *user;
@property (nonatomic) SBSessionData *sessionData;

- (id)initWithIdentifier:(NSString*)identifier
               userClass:(Class)userClass;

@end

@interface FFSession ()

@property (nonatomic, assign) BOOL shouldStopFetchUser;

@end

@implementation FFSession

// custom init
- (id)initWithIdentifier:(NSString*)identifier
               userClass:(Class)userClass
{
    self = [super initWithIdentifier:identifier
                           userClass:userClass];
    if (self) {
        self.sport = [self currentSport];
    }
    return self;
}

- (FFMarketSport)currentSport
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentSport] integerValue];
}

- (void)clearCredentials
{
    [AFOAuthCredential deleteCredentialWithIdentifier:self.identifier];
    [self.authorizedHttpClient clearAuthorizationHeader];
}

- (id)deserializeJSON:(id)JSON
{
    if (JSON[@"data"] && [JSON[@"data"] isKindOfClass:[NSArray class]]) {
        // it's JSONH
        NSArray* lst = JSON[@"data"];
        if (!lst.count) {
            return [NSArray array];
        }
        NSMutableArray* ret = [NSMutableArray array];
        NSInteger klength = [lst[0] integerValue];
        NSInteger i = 1 + klength;
        while (i < lst.count) {
            NSMutableDictionary* d = [NSMutableDictionary dictionary];
            NSInteger ki = 0;
            while (ki < klength) {
                ki++;
                d[lst[ki]] = lst[i];
                i++;
            }
            [ret addObject:d];
        }
        return ret;
    }
    return JSON;
}

- (void)registerAndLoginUsingFBAccessToken:(NSString*)accessToken fbUid:(NSString*)fbuid
                                   success:(SBSuccessBlock)success
                                   failure:(SBErrorBlock)failure
{
    [self clearCredentials];
    NSDictionary* params = @{
        @"access_token" : accessToken
    };

    NSMutableURLRequest* req = [self.anonymousHttpClient requestWithMethod:@"POST"
                                                                      path:@"/users/auth/facebook_access_token/callback"
                                                                parameters:params];
    [req setValue:@"application/json"
        forHTTPHeaderField:@"Accept"];

    SBJSONRequestOperation* op = [[SBJSONRequestOperation alloc] initWithRequest:req];

    FFUser* user = [[FFUser alloc] initWithSession:self];
    user.fbUid = fbuid;

    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"got fb login response response %@", responseObject);
        [user setValuesForKeysWithNetworkDictionary:responseObject];
        [user save];
        self.user = user;
        [self.sessionData save];
        [self getOAuth:user fbAccessToken:accessToken success:^(id successObj)
        {
            self.sessionData.userKey = user.key;
            [self.sessionData save];
            success(user);
        }
    failure:
        ^(NSError * error)
        {
            failure(error);
        }];
    }
failure:
    ^(AFHTTPRequestOperation * operation, NSError * error)
    {
        NSLog(@"register failed to post user operation=%@ error=%@", operation, error);
        failure(error);
    }];
    [self.anonymousHttpClient enqueueHTTPRequestOperation:op];
}

- (void)getOAuth:(FFUser*)user
   fbAccessToken:(NSString*)accessToken
         success:(SBSuccessBlock)success
         failure:(SBErrorBlock)err
{
    [self clearCredentials];

    NSMutableDictionary* mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:@"facebook"
                          forKey:@"grant_type"];
    [mutableParameters setObject:accessToken
                          forKey:@"token"];
    [mutableParameters setObject:user.fbUid
                          forKey:@"uid"];
    NSDictionary* parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];

    [self.authorizedHttpClient authenticateUsingOAuthWithPath:@"/oauth2/token" parameters:parameters success:
     ^(AFOAuthCredential *credential)
    {
        //
        [AFOAuthCredential storeCredential:credential
                            withIdentifier:self.identifier];
        success(user);
    }
failure:
    ^(NSError * error)
    {
        //
        err(error);
    }];
}

- (void)authorizedJSONRequestWithRequestBlock:(NSURLRequest* (^)(void))requestBlock
                                      success:(void (^)(NSURLRequest*, NSHTTPURLResponse*, id))success
                                      failure:(void (^)(NSURLRequest*, NSHTTPURLResponse*, NSError*, id))failure
{
    // wrap all authorized requests so we can log the error to Ubertesters.
    [super authorizedJSONRequestWithRequestBlock:requestBlock success:success failure:
     ^void (NSURLRequest *req, NSHTTPURLResponse *resp, NSError *err, id res)
    {
        [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"AuthorizedRequestError: %@", err]
                          withLevel:UTLogLevelError];
        failure(req, resp, err, res);
    }];
}

- (void)anonymousJSONRequestWithMethod:(NSString*)method
                                  path:(NSString*)path
                            parameters:(NSDictionary*)params
                               success:(void (^)(NSURLRequest*, NSHTTPURLResponse*, id))success
                               failure:(void (^)(NSURLRequest*, NSHTTPURLResponse*, NSError*, id))failure
{
    // wrap all anonymous requests so we can log the error to Ubertesters.
    [super anonymousJSONRequestWithMethod:method path:path parameters:params success:success failure:
     ^void (NSURLRequest *req, NSHTTPURLResponse *resp, NSError *err, id ret)
    {
        [[Ubertesters shared] UTLog:[NSString stringWithFormat:@"AnonymousRequestError: %@", err]
                          withLevel:UTLogLevelError];
        failure(req, resp, err, ret);
    }];
}

- (void)getOAuth:(SBUser *)user password:(NSString *)password success:(SBSuccessBlock)success failure:(SBErrorBlock)failure
{
    [self.authorizedHttpClient authenticateUsingOAuthWithPath:@"/oauth2/token" username:user.email
                                                     password:password scope:nil success:
     ^(AFOAuthCredential *credential) {
         [AFOAuthCredential storeCredential:credential withIdentifier:self.identifier];
         success(user);
     } failure:^(NSError *error) {
         NSLog(@"oauth crapped %@", error);
         NSError *dumbError = [NSError errorWithDomain:@"" code:400 userInfo:
                               @{ NSUnderlyingErrorKey: error,
                                  NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid username or password", nil) }];
         failure(dumbError);
         //because 2 popups with errors
         //         failure(error);
     }];
}

- (void)logout
{
    self.shouldStopFetchUser = YES;
    // delete everything!
    [[SBSessionData meta] removeAll];
    [[FFMarket meta] removeAll];
    [[FFContestType meta] removeAll];
    [[FFUser meta] removeAll];
    [[FFRoster meta] removeAll];
    [self.authorizedHttpClient clearAuthorizationHeader];
    // remove all user defaults stuff
    NSString* appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super logout];
}

#pragma mark - inheritance

// do not save models any more
- (void)syncUserSuccess:(SBSuccessBlock)success failure:(SBErrorBlock)failure
{
    [self authorizedJSONRequestWithMethod:@"GET" path:@"/users.json" paramters:@{} success:
     ^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
         [self.user setValuesForKeysWithNetworkDictionary:JSON];
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
             [self.user save];
             success(self.user);
             NSLog(@"successfully got and saved user");
             //             [self syncPushToken];
         });
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
         NSLog(@"failed to get current user error=%@ json=%@", error, JSON);
         failure(error);
     }];
}

// loading object for current sport only

- (SBModelQueryBuilder *)queryBuilderForClass:(Class)modelCls
{
    return [[super queryBuilderForClass:modelCls] property:@"sportKey"
                                                 isEqualTo:[FFSportHelper stringFromSport:self.sport]];
}

- (SBModelQueryBuilder *)unsafeQueryBuilderForClass:(Class)modelCls
{
    return [[super unsafeQueryBuilderForClass:modelCls] property:@"sportKey"
                                                       isEqualTo:[FFSportHelper stringFromSport:self.sport]];
}

#pragma mark - user retrieving

- (void)pollUser
{
    [self syncUserSuccess:^(id successObj)
     {
         FFUser* user = successObj;
         if ([self.delegate respondsToSelector:@selector(didUpdateUser:)]) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.delegate didUpdateUser:user];
             });
         }
         CGFloat delayInSeconds = 10.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
             if (!self.shouldStopFetchUser)
                 [self pollUser];
         });
     }
                          failure:
     ^(NSError * error)
     {
         CGFloat delayInSeconds = 10.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
             if (!self.shouldStopFetchUser)
                 [self pollUser];
         });
     }];
}

- (void)updateUserNow
{
    [self syncUserSuccess:^(id successObj)
     {
         FFUser* user = successObj;
         if ([self.delegate respondsToSelector:@selector(didUpdateUser:)]) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.delegate didUpdateUser:user];
             });
         }
     }
                          failure:
     ^(NSError * error)
     {
         NSLog(@"failed to get user");
     }];
}

#pragma mark - public

- (FFUser *)user
{
    return (FFUser*)[super user];
}

- (SBSessionData *)sessionData
{
    return [super sessionData];
}

@end

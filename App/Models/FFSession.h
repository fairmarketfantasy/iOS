//
//  FFSession.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/19/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import <SBSession.h>
#import "FFUser.h"
#import "FFSport.h"

@protocol FFUserProtocol <NSObject>

@optional
- (void)didUpdateUser:(FFUser*)user;

@end

@interface FFSession : SBSession

@property(nonatomic, readonly) FFUser* user;
@property(nonatomic, assign) FFMarketSport sport;
@property(nonatomic, readonly) SBSessionData* sessionData;
@property(nonatomic, weak) id <FFUserProtocol> delegate;

- (void)registerAndLoginUsingFBAccessToken:(NSString*)accessToken
                                     fbUid:(NSString*)fbUid
                                   success:(SBSuccessBlock)success
                                   failure:(SBErrorBlock)failure;
- (void)clearCredentials;

#pragma mark -

- (void)pollUser;

/**
 * updates a user immediately
 * eg the user just bought some tokens,
 * or an in-progress roster changed
 */
- (void)updateUserNow;

@end

//
//  FFUser.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/10/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFUser.h"
#import <SBData/NSDictionary+Convenience.h>
#import "FFDate.h"
#import "FFRoster.h"
#import "FFSession.h"
#import <objc/runtime.h>

@implementation FFUser

@dynamic name;
@dynamic imageUrl;
@dynamic balance;
@dynamic joinDate;
@dynamic winPercentile;
@dynamic tokenBalance;
@dynamic email;
@dynamic totalPoints;
@dynamic totalWins;
@dynamic inProgressRoster;
@dynamic prestige;
@dynamic fbUid;
@dynamic customerObject;

+ (NSString *)tableName { return @"ffuser"; }

+ (void)load { [self registerModel:self]; }

- (NSString *)listPath { return @"/users.json"; }

- (NSString *)detailPathSpec { return @"/users.json"; }

// customize the to the nonstandard way the /users endpoint works
- (AFHTTPClientParameterEncoding)paramterEncoding { return AFFormURLParameterEncoding; }

+ (NSDictionary *)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:@{
                @"userId":           @"id",
                @"name":             @"name",
                @"imageUrl":         @"image_url",
                @"balance":          @"balance",
                @"tokenBalance":     @"token_balance",
                @"totalPoints":      @"total_points",
                @"totalWins":        @"total_wins",
                @"winPercentile":    @"win_percentile",
                @"email":            @"email",
                @"joinDate":         @"joined_at",
                @"inProgressRoster": @"in_progress_roster",
                @"prestige":         @"prestige",
                @"customerObject": @"customer_object"
            }];
}

- (NSDictionary *)toNetworkRepresentation
{
    return @{ @"user": [super toNetworkRepresentation] };
}

- (void)setValuesForKeysWithNetworkDictionary:(NSDictionary*)keyedValues
{
    [super setValuesForKeysWithNetworkDictionary:keyedValues];
    // TODO: get in_progress_roster ???
    /*
    if ([keyedValues[@"in_progress_roster"] isKindOfClass:[NSDictionary class]]) {
        [FFRoster createWithNetworkRepresentation:keyedValues[@"in_progress_roster"]
                                          session:self.session
                                          success:^(id successObj) {
                                          } failure:^(NSError *error) {
                                          }];
    }
     */
}

- (FFRoster *)getInProgressRoster
{
    NSString *rosterId = self.inProgressRoster[@"id"];
    if (rosterId) {
        return [[[[[self.session queryBuilderForClass:[FFRoster class]] property:@"objId"
                                                                       isEqualTo:rosterId]
                  query] results] first];
    }
    return nil;
}

#pragma mark - public

- (void)updateName:(NSString*)name
         withBlock:(SBSuccessBlock)onSuccess
           failure:(SBErrorBlock)onFailure
{
    [self updateInBackgroundBody:@{
                                   [[self class] propertyToNetworkKeyMapping][@"name"] : name // TODO: refactore me
                                   }
                       withBlock:onSuccess
                         failure:onFailure];
}

- (void)updateAvatar:(NSString*)avatarURLPath
           withBlock:(SBSuccessBlock)onSuccess
             failure:(SBErrorBlock)onFailure
{
    [self updateInBackgroundBody:@{
                                   [[self class] propertyToNetworkKeyMapping][@"imageUrl"] : avatarURLPath
                                   }
                       withBlock:onSuccess
                         failure:onFailure];
}

- (void)updateEmail:(NSString*)eMail
          withBlock:(SBSuccessBlock)onSuccess
            failure:(SBErrorBlock)onFailure
{
    [self updateInBackgroundBody:@{
                                   [[self class] propertyToNetworkKeyMapping][@"email"] : eMail
                                   }
                       withBlock:onSuccess
                         failure:onFailure];
}

// TODO: md5 !!!
- (void)updatePassword:(NSString*)password
               current:(NSString*)current
             withBlock:(SBSuccessBlock)onSuccess
               failure:(SBErrorBlock)onFailure
{
    [self updateInBackgroundBody:@{
                                   @"current_password" : current,
                                   @"password" : password,
                                   @"password_confirmation" : password // ???: orly
                                   }
                       withBlock:onSuccess
                         failure:onFailure];
}

#pragma mark - private

- (NSDictionary*)updateBody:(NSDictionary*)body
{
    NSMutableDictionary* wholeBody = [NSMutableDictionary dictionaryWithDictionary:body];
    [wholeBody setObject:self.objId
                  forKey:@"id"];
    return @{ @"user" : [wholeBody copy]};
}

- (void)updateInBackgroundBody:(NSDictionary*)body
                     withBlock:(SBSuccessBlock)onSuccess
                       failure:(SBErrorBlock)onFailure
{
    NSParameterAssert(self.session != nil);
    AFHTTPClient* client = self.authorized ? self.session.authorizedHttpClient : self.session.anonymousHttpClient;
    SBJSONRequestOperation* operation = [[SBJSONRequestOperation alloc] initWithRequest:
                                         [client requestWithMethod:@"PUT"
                                                              path:[self path]
                                                        parameters:[self updateBody:body]]];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_queue_t queue = (dispatch_queue_t)objc_getAssociatedObject([self class], "processingQueue");
        dispatch_async(queue, ^{
            [[[self class] meta] inTransaction:^(SBModelMeta *meta, BOOL *rollback) {
                [self setValuesForKeysWithNetworkDictionary:responseObject];
                [meta save:self];
                dispatch_async(dispatch_get_main_queue(), ^{
                    onSuccess(self);
                });
            }];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        onFailure(error);
    }];
    [client enqueueHTTPRequestOperation:operation];
}

@end

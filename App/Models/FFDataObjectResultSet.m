//
//  SBDataObject+RefreshWithParameters.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObjectResultSet.h"

@interface SBDataObjectResultSet () {
    dispatch_queue_t _processingQueue;
}
@end

@implementation SBDataObjectResultSet (ProcessingQueue)

- (dispatch_queue_t)processingQueue
{
    return self->_processingQueue;
}

@end

@implementation FFDataObjectResultSet

- (void)refreshWithParameters:(NSDictionary*)parameters
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultSetWillReload:)]) {
        [self.delegate resultSetWillReload:self];
    }
    [self.session authorizedJSONRequestWithMethod:@"GET"
                                             path:[self path]
                                        paramters:parameters
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON)
    {
        NSLog(@"got json: %@", JSON);
        if ([super respondsToSelector:@selector(_setBeforeParams:)]) {
            [super performSelector:@selector(_setBeforeParams:)
                        withObject:JSON];
        }
        dispatch_async([self processingQueue], ^{
            if (self.clearsCollectionBeforeSaving) {
                [[self query] removeAll];
            }
            NSArray* replacement = @[];
            if ([super respondsToSelector:@selector(_processPage:)]) {
                id array = [super performSelector:@selector(_processPage:)
                                       withObject:JSON];
                if ([array isKindOfClass:[NSArray class]]) {
                    replacement = array;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([super respondsToSelector:@selector(_reset:)]) {
                    [super performSelector:@selector(_reset:)
                                withObject:replacement];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(resultSetDidReload:)]) {
                    [self.delegate resultSetDidReload:self];
                }
            });
        });
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
    {
        NSLog(@"got error: %@ JSON: %@", error, JSON);
        if (self.delegate && [self.delegate respondsToSelector:@selector(resultSet:
                                                                   didFailToReload:)]) {
            [self.delegate resultSet:self
                     didFailToReload:error];
        }
    }];
}

@end

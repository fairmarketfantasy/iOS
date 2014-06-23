//
//  FFWCDataModel.h
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFWCDataModel : NSObject
{
@protected
    NSString *_name;
    NSString *_flagURL;
    NSString *_statsId;
    NSInteger _pt;
    BOOL _disablePT;
    BOOL _isPtHidden;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *flagURL;
@property (nonatomic, readonly) NSString *statsId;
@property (nonatomic, readonly) NSInteger pt;
@property (nonatomic, assign) BOOL disablePT;
@property (nonatomic, readonly) BOOL isPtHidden;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

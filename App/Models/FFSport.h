//
//  FFSport.h
//  FMF Football
//
//  Created by Anton Chuev on 5/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"

@interface FFSport : NSObject

@property (nonatomic, readonly) BOOL commingSoon;
@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, readonly) BOOL isPlayoffsOn;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *title;//for showing in menu

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end

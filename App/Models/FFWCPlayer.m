//
//  FFWCPlayer.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCPlayer.h"
#import "FFWCDataModel.h"

@implementation FFWCPlayer

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        _name = dict[@"name"];
        _flagURL = dict[@"logo_url"];
        _statsId = dict[@"stats_id"];
        _pt = [dict[@"pt"] integerValue];
        _disablePT = [dict[@"disable_pt"] boolValue];
        _isPtHidden = [dict[@"remove_pt"] boolValue];
    }
    
    return self;
}

@end

//
//  FFDate.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/9/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBTypes.h"

/** fix UTC date formatting */
@interface FFDate : SBDate

+ (NSDateFormatter*)dateFormatter;
+ (NSDateFormatter *)prettyDateFormatter;

@end

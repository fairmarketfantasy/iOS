//
//  FFCategory.h
//  FMF Football
//
//  Created by Anton Chuev on 5/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"

@interface FFCategory : FFDataObject

@property (nonatomic) NSString *categoryID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *note;
@property (nonatomic) NSArray *sports;

@end

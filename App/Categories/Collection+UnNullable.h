//
//  Collection+UnNullable.h
//  OXID_Shop
//
//  Created by DAloG on 17.05.11.
//  Copyright 2011 MobiDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol INullRemoval <NSObject>

-(id) removeNulls;

@end

@interface NSDictionary (UnNullable)<INullRemoval>
@end

@interface NSArray (UnNullable)<INullRemoval>
@end

@interface NSSet (UnNullable)<INullRemoval>
@end

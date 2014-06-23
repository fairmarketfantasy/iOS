//
//  Collection+UnNullable.m
//  OXID_Shop
//
//  Created by DAloG on 17.05.11.
//  Copyright 2011 MobiDev. All rights reserved.
//

#import "Collection+UnNullable.h"


@implementation NSDictionary (UnNullable)

- (id)removeNulls
{
	NSMutableDictionary* result = [self mutableCopy];
	
	// Remove nulls
	NSArray* nulls = [self allKeysForObject:[NSNull null]];
	for (id key in nulls) 
	{ 
		[result removeObjectForKey:key];
	}
	
	// Recursion
	for (id key in self) 
	{
		id value = [self objectForKey:key];
		
		if ([value conformsToProtocol:@protocol(INullRemoval)])
		{
			[result setObject:[value removeNulls] forKey:key];
		}
	}
	
	return result;
}

@end

@implementation NSArray(UnNullable)

- (id)removeNulls
{
	NSMutableArray* result = [self mutableCopy];
	
	[result removeObject:[NSNull null]];
	
	for (id item in self) 
	{
		if ([item conformsToProtocol:@protocol(INullRemoval)])
		{
			NSUInteger index = [result indexOfObject:item];
			[result replaceObjectAtIndex:index withObject:[item removeNulls]];
		}
	}
	
	return result;
}

@end

@implementation NSSet(UnNullable)

- (id)removeNulls
{
	NSMutableSet* result = [self mutableCopy];
	
	[result removeObject:[NSNull null]];
	
	for (id item in self) 
	{
		if ([item conformsToProtocol:@protocol(INullRemoval)])
		{
			[result removeObject:item];
			[result addObject:[item removeNulls]];
		}
	}
	
	return result;
}

@end

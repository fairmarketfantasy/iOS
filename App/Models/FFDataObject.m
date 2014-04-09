//
//  FFDataObject.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/9/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"
#import <objc/runtime.h>
#import <SBDataObjectTypes.h>
#import <SBModel_SBModelPrivate.h>

#import "FFDate.h"

@interface FFSBISO8601DateConverter : NSObject <SBNetworkFieldConverting>
@end

@implementation FFDataObject

// fix date format
+ (id<SBNetworkFieldConverting>)networkFieldConverterForField:(NSString *)fieldName
{
    NSDictionary *defaultConverters = objc_getAssociatedObject(self, @"networkFieldConverters");
    if (!defaultConverters) {
        NSMutableDictionary *converters = [[NSMutableDictionary alloc] init];
        // look at the properties of this class and attempt to set sane default
        // converters for the known properties
        NSArray *props = [self allFieldNames];
        for (NSString *key in props) {
            Class kls = [self classForPropertyName:key];
            if (kls && [kls conformsToProtocol:@protocol(SBField)]) {
                if ([kls isSubclassOfClass:[SBInteger class]]){
                    [converters setObject:[SBIntegerConverter new] forKey:key];
                }
                else if ([kls isSubclassOfClass:[SBString class]]) {
                    [converters setObject:[SBStringConverter new] forKey:key];
                }
                else if ([kls isSubclassOfClass:[SBFloat class]]) {
                    [converters setObject:[SBFloatConverter new] forKey:key];
                }
                else if ([kls isSubclassOfClass:[FFDate class]]) { // fix UTC format
                    [converters setObject:[FFSBISO8601DateConverter new] forKey:key];
                }
                else if ([kls isSubclassOfClass:[SBDate class]]) {
                    [converters setObject:[SBISO8601DateConverter new] forKey:key];
                }
            }
        }
        defaultConverters = [converters copy];
        objc_setAssociatedObject(self, @"networkFieldConverters",
                                 defaultConverters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [defaultConverters objectForKey:fieldName];
}

@end

@implementation FFSBISO8601DateConverter

- (id<SBField>)fromNetwork:(id)value
{
    NSString* string = (NSString*)value;
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSDateFormatter* formatter = [FFDate dateFormatter];
    NSDate* date = [formatter dateFromString:string];
    FFDate* dateObject = [[FFDate alloc] initWithDate:date];
    return dateObject;
}

- (id)toNetwork:(id<SBField>)value
{
    FFDate* date = (FFDate*)value;
    if (![date isKindOfClass:[FFDate class]]) {
        return nil;
    }
    NSDateFormatter* formatter = [FFDate dateFormatter];
    NSString* string = [formatter stringFromDate:date];
    return string;
}

@end

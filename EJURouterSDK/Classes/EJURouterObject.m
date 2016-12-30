//
//  EJURouterObject.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "EJURouterObject.h"

@class EJURouterWebViewController;

@implementation EJURouterDataModel
{
    NSString *_desc;
}

- (instancetype)init {
    if (self = [super init]) {
        self.type = EJURouterPageTypeUnknown;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        _desc = value;
    }
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    [super setValuesForKeysWithDictionary:keyedValues];
    
    switch (_type) {
        case EJURouterPageTypeNative:
            _className = _resource;
            break;
        case EJURouterPageTypeLocalHtml:
            _className = @"EJURouterWebViewController";
            break;
        case EJURouterPageTypeWeb:
            _className = @"EJURouterWebViewController";
            break;
        default:
            _className = nil;
            break;
    }
}

- (void)setDescription:(NSString *)description {
    _desc = description;
}

- (NSString *)description {
    return _desc;
}

@end

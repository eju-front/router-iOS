//
//  EJURouterSDK.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "EJURouterSDK.h"
#import "EJURouterMapUpdater.h"
#import "EJURouterNavigator.h"
#import "EJURouterVCMap.h"

@implementation EJURouterSDK

+ (void)startServiceWithConfiguration:(EJURouterConfiguration *)configuration;
{
    // 读取配置表
    EJURouterVCMap *map = [[EJURouterVCMap alloc]init];
    [map readVCMap];
    
    // 初始化navigator，并赋值配置表
    [EJURouterNavigator sharedNavigator].map = map;
    // 配置
    [EJURouterNavigator sharedNavigator].configuration = configuration;
    
    // 启动更新
    [EJURouterMapUpdater updateMap];
}

@end

@implementation EJURouterConfiguration

+ (instancetype)configurationWithNotFoundPageClass:(Class)notFoundPageClass urlScheme:(NSString *)scheme urlHost:(NSString *)host updateRequest:(NSURLRequest *)updateRequest
{
    EJURouterConfiguration *config = [[self alloc]init];
    config.notFoundPageClass = notFoundPageClass;
    config.urlScheme = scheme;
    config.urlHost = host;
    config.updateRequest = updateRequest;
    return config;
}

- (NSString *)urlScheme {
    if (!_urlScheme) {
        _urlScheme = @"ejurouter";
    }
    return _urlScheme;
}

- (NSString *)host {
    if (!_urlHost) {
        _urlHost = @"page";
    }
    return _urlHost;
}

@end

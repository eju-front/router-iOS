//
//  EJURouterSDK.h
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EJURouterConfiguration;
@interface EJURouterSDK : NSObject

/**
 启动服务
 */
+ (void)startServiceWithConfiguration:(EJURouterConfiguration *)configuration;

@end

@interface EJURouterConfiguration : NSObject

/**
 未找到页面Class
 */
@property (nonatomic, assign)   Class              notFoundPageClass;

/**
 h5跳native页面的urlScheme
 */
@property (nonatomic, copy)     NSString           *urlScheme;

/**
 h5跳native页面urlHost
 */
@property (nonatomic, copy)     NSString           *urlHost;

/**
 更新请求
 */
@property (nonatomic, strong)   NSURLRequest       *updateRequest;


/**
 快速创建实例
 @return 返回实例对象
 */
+ (instancetype)configurationWithNotFoundPageClass:(Class)notFoundPageClass urlScheme:(NSString *)scheme urlHost:(NSString *)host updateRequest:(NSURLRequest *)updateRequest;

@end

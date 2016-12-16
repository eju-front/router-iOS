//
//  EJURouterSDK.h
//  Pods
//
//  Created by 施澍 on 2016/11/25.
//
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

@property (nonatomic, assign)   Class              notFoundPageClass;
@property (nonatomic, copy)     NSString           *urlScheme;
@property (nonatomic, strong)   NSURLRequest       *updateRequest;

+ (instancetype)configurationWithNotFoundPageClass:(Class)notFoundPageClass urlScheme:(NSString *)urlScheme updateRequest:(NSURLRequest *)updateRequest;

@end

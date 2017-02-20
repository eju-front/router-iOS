//
//  EJUNavigator.h
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EJURouterSDKDefine.h"

@class EJURouterVCMap;
@class EJURouterConfiguration;
@class EJURouterDataModel;

@interface EJURouterNavigator : NSObject

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) EJURouterVCMap *map;
@property (nonatomic, strong) EJURouterConfiguration *configuration;


/**
 导航单例

 @return 单例
 */
+ (instancetype)sharedNavigator;


/**
 打开ID对应的视图控制器（不带参）

 @param identifier 视图控制器对应的唯一标识
 @param completion 完成回调
 */
- (void) openId:(NSString *)identifier
jsFunctionArray:(NSArray *)jsFunctionArray
   onCompletion:(EJURouterCompletionBlock)completion;

/**
 打开ID对应的视图控制器（带参）

 @param identifier      视图控制器对应的唯一标识
 @param params          参数
 @param jsFunctionArray js方法名 数组
 @param completion      完成回调
 */
- (void) openId:(NSString *)identifier
         params:(NSDictionary *)params
jsFunctionArray:(NSArray *)jsFunctionArray
   onCompletion:(EJURouterCompletionBlock)completion;

/**
 打开ID对应的视图控制器（从xib中加载）

 @param identifier      视图控制器对应的唯一标识
 @param params          参数
 @param jsFunctionArray js方法名 数组
 @param completion      完成回调
 */
- (void)openFromXibWithId:(NSString *)identifier
                   params:(NSDictionary *)params
          jsFunctionArray:(NSArray *)jsFunctionArray
             onCompletion:(EJURouterCompletionBlock)completion;

/**
 打开ID对应的视图控制器（从storyboard中加载）

 @param identifier      视图控制器对应的唯一标识
 @param sbName          storyboard名称
 @param sbId            视图控制器在sb中的ID
 @param params          参数
 @param jsFunctionArray js方法名 数组
 @param completion      完成回调
 */
- (void)openFromStoryboardWithId:(NSString *)identifier
                          sbName:(NSString *)sbName
                            sbId:(NSString *)sbId
                          params:(NSDictionary *)params
                 jsFunctionArray:(NSArray *)jsFunctionArray
                    onCompletion:(EJURouterCompletionBlock)completion;

/**
 以模态化方式打开ID对应的视图控制器

 @param identifier      视图控制器对应的唯一标识
 @param fromVC          由何视图控制器弹出
 @param params          参数
 @param jsFunctionArray js方法名 数组
 @param completion      回调
 */
- (void)presentId:(NSString *)identifier
             from:(UIViewController *)fromVC
           params:(NSDictionary *)params
  jsFunctionArray:(NSArray *)jsFunctionArray
     onCompletion:(EJURouterCompletionBlock)completion;

/**
 以模态化方式打开ID对应的视图控制器（从xib加载）

 @param identifier      视图控制器对应的唯一标识
 @param fromVC          由何视图控制器弹出
 @param params          参数
 @param jsFunctionArray js方法名 数组
 @param completion      回调
 */
- (void)presentXibWithId:(NSString *)identifier
                    from:(UIViewController *)fromVC
                  params:(NSDictionary *)params
         jsFunctionArray:(NSArray *)jsFunctionArray
            onCompletion:(EJURouterCompletionBlock)completion;

/**
 以模态化方式打开ID对应的视图控制器（从storyboard加载）

 @param identifier      视图控制器对应的唯一标识
 @param sbName          storyboard名称
 @param sbId            视图控制器在sb中的ID
 @param fromVC          由何视图控制器弹出
 @param params          参数
 @param jsFunctionArray js方法名 数组
 @param completion      回调
 */
- (void)presentSBWithId:(NSString *)identifier
                 sbName:(NSString *)sbName
                   sbId:(NSString *)sbId
                   from:(UIViewController *)fromVC
                 params:(NSDictionary *)params
        jsFunctionArray:(NSArray *)jsFunctionArray
           onCompletion:(EJURouterCompletionBlock)completion;


/**
 寻找ID对应的视图控制器数据模型

 @param identifier 唯一标识

 @return ID对应的视图控制器模型
 */
- (EJURouterDataModel *)findVcWithId:(NSString *)identifier;


/**
 打开某个URL（webviewcontroller用）

 @param url 地址

 @return 是否打开新页面
 */
- (BOOL)willOpenUrlInNewPage:(NSURL *)url;

@end

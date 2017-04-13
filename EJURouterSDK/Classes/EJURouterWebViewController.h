//
//  EJURouterWebViewController.h
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EJURouterWebViewController : UIViewController

@property (nonatomic, strong) NSURL         *url;
@property (nonatomic, copy)   NSDictionary  *params;
@property (nonatomic, strong) NSArray *jsFunctionNameArrays;        //js方法名 数组
@property (nonatomic, assign) BOOL changeNaviBarColorWithSwipe;     //是否需要上下滑动屏幕时，改变导航栏背景色

- (void)loadWithUrl:(NSURL *)url andParams:(NSDictionary *)params;

@end

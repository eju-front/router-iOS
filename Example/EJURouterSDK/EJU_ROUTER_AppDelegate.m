//
//  EJU_ROUTER_AppDelegate.m
//  EJURouterSDK
//
//  Created by seth on 11/25/2016.
//  Copyright (c) 2016 seth. All rights reserved.
//

#import "EJU_ROUTER_AppDelegate.h"
#import <EJURouterSDK/EJURouterSDK.h>
#import <EJURouterSDK/EJURouterNavigator.h>
#import <WebKit/WebKit.h>

@implementation EJU_ROUTER_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *updateUrlStr = @"http://172.29.32.215:10086/app/checkViewMap?appName=com.cric.EJURouterSDK-Example&os=ios";
    NSURL *updateUrl = [NSURL URLWithString:[updateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *updateRequest = [NSURLRequest requestWithURL:updateUrl];
    EJURouterConfiguration *config = [EJURouterConfiguration configurationWithNotFoundPageClass:nil urlScheme:@"ejurouter" urlHost:@"page" updateRequest:updateRequest];
    [EJURouterSDK startServiceWithConfiguration:config];
    
    //注册监听
    [self addNotifications];
    
    return YES;
}

//注册监听
- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidStart:) name:@"WebViewDidStart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidCommit:) name:@"WebViewDidCommit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFinish:) name:@"WebViewDidFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFail:) name:@"WebViewDidFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidReceiveScriptMessage:) name:@"WebViewDidReceiveScriptMessage" object:nil];
}

// web页面开始加载时调用
- (void)webViewDidStart:(NSNotification *)notification {
    
    NSLog(@"StartClass===%@",[notification.object class]);
}

// 当web页内容开始返回时调用
- (void)webViewDidCommit:(NSNotification *)notification {
    
    NSLog(@"CommitClass===%@",[notification.object class]);
}

// web页面加载完成之后调用
- (void)webViewDidFinish:(NSNotification *)notification {
    
    NSLog(@"FinishClass===%@",[notification.object class]);
    WKWebView *webView = (WKWebView *)notification.object;
    
    //native调js
    [webView evaluateJavaScript:@"easyLiveShareSuccess('wechat')" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        //TODO
        NSLog(@"response===%@ , error===%@",response,error);
    }];
}

// web页面加载失败时调用
- (void)webViewDidFail:(NSNotification *)notification {
    
    NSLog(@"FailClass===%@",[notification.object class]);
    NSLog(@"error====%@",[notification.userInfo objectForKey:@"error"]);
}

// js调native，返回js传递的参数
- (void)webViewDidReceiveScriptMessage:(NSNotification *)notification {
    
    WKScriptMessage *message = (WKScriptMessage *)notification.object;
    NSLog(@"message.name=%@,message.body=%@",message.name,message.body);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

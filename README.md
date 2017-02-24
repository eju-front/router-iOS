# EJURouter

[![Build Status](https://travis-ci.org/eju-front/router-iOS.svg?branch=master)](https://travis-ci.org/eju-front/router-iOS)
[![Version](https://img.shields.io/cocoapods/v/EJURouterSDK.svg?style=flat)](http://cocoapods.org/pods/EJURouterSDK)
[![License](https://img.shields.io/cocoapods/l/EJURouterSDK.svg?style=flat)](http://cocoapods.org/pods/EJURouterSDK)
[![Platform](https://img.shields.io/cocoapods/p/EJURouterSDK.svg?style=flat)](http://cocoapods.org/pods/EJURouterSDK)

## 环境要求
iOS8.0及以上

## 使用介绍

在`AppDelegate`中`application:didFinishLaunchingWithOptions:`方法调用启动服务方法：

~~~obj	
//需要指定更新请求对象，否则将无法自动更新map表
NSString *updateUrlStr = @"";
NSURL *updateUrl = [NSURL URLWithString:[updateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
NSURLRequest *updateRequest = [NSURLRequest requestWithURL:updateUrl];
EJURouterConfiguration *config = [EJURouterConfiguration configurationWithNotFoundPageClass:nil urlScheme:@"ejurouter" urlHost:@"" updateRequest:updateRequest];
[EJURouterSDK startServiceWithConfiguration:config];
~~~

注册监听（监听`WKWebView`的加载过程）：

~~~obj
// web页面开始加载时调用
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidStart:) name:@"WebViewDidStart" object:nil];

// 当web页内容开始返回时调用
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidCommit:) name:@"WebViewDidCommit" object:nil];

// web页面加载完成之后调用
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFinish:) name:@"WebViewDidFinish" object:nil];

// web页面加载失败时调用
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFail:) name:@"WebViewDidFail" object:nil];

// js调native，返回js传递的参数
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidReceiveScriptMessage:) name:@"WebViewDidReceiveScriptMessage" object:nil];
~~~

实现监听事件：

~~~obj
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
~~~

打开页面：

~~~obj
[[EJURouterNavigator sharedNavigator]openId:@"native" params:@{} jsFunctionArray:@[] onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
}];
~~~

## viewMap配置表（plist格式）
~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<string>V1.0.4</string>
	<dict>
		<key>identifier</key>
		<string>native</string>
		<key>resource</key>
		<string>TestNativeViewController</string>
		<key>type</key>
		<string>0</string>
		<key>description</key>
		<string>Native</string>
	</dict>
	<dict>
		<key>identifier</key>
		<string>localhtml1</string>
		<key>resource</key>
		<string>test1.html</string>
		<key>type</key>
		<string>2</string>
		<key>description</key>
		<string>LocalHtml</string>
	</dict>
	<dict>
		<key>identifier</key>
		<string>localhtml2</string>
		<key>resource</key>
		<string>test2.html</string>
		<key>type</key>
		<string>2</string>
		<key>description</key>
		<string>LocalHtml</string>
	</dict>
	<dict>
		<key>identifier</key>
		<string>web</string>
		<key>resource</key>
		<string>http://10.0.60.95:8090/easyliveh5/</string>
		<key>type</key>
		<string>3</string>
		<key>description</key>
		<string>Web</string>
	</dict>
	<dict>
		<key>identifier</key>
		<string>web2</string>
		<key>resource</key>
		<string>http://10.0.60.95:8090/easyliveh5/demo.html</string>
		<key>type</key>
		<string>3</string>
		<key>description</key>
		<string>Web</string>
	</dict>
</array>
</plist>
~~~
```
identifier :页面唯一标识符
description : 页面描述
resource :页面的全路径
type :页面类型
```
```
EJURouterPageTypeNativeWithPush             = 0,  (原生Push)
EJURouterPageTypeNativeWithPresent          = 1,  (原生Present)
EJURouterPageTypeLocalHtml                  = 2,  (本地H5)
EJURouterPageTypeWeb                        = 3,  (web)
EJURouterPageTypeUnknown                    = -1, (未知)
```

## viewMap文件说明
APP保留一份默认的 ```viewmap``` 文件,作为初始化文件，初始版本可在 ```Router``` 初始化的时候指定。默认初始版本为 <code>V1.0.0</code>。<strong>请按照相关规范命名版本号，要么统一v或者V开头，要么直接是1.0.1的样式初始化的时候需要指定更新的 url(应该包含应用名称标识和平台标识)。</strong>

## viewMap更新说明:
`SDK`会在应用每次<strong>启动的时候</strong>加载本地最新的配置文件和检测服务器最新的配置文件，如果需要更新，将会自动下载最新的配置文件，<strong>在下一次重新启动应用的时候读取下载的配置文件参数，执行新的逻辑</strong>

## 注意事项
* 网页端人员通过`URL`打开`Native`页面时，需要和移动端提前约定好`Scheme`；
* 网页端通过`URL`带参打开`Native`页面是，需要注意移动端暂时只接收`String`和`JSON`类型参数，移动端需要注意在定义接收参数类型时，只能为`NSString`、`NSDictionary`、`NSArray`；
* `map`表中需要指定版本。

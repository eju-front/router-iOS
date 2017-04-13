//
//  EJURouterWebViewController.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "EJURouterWebViewController.h"
#import "EJURouterNavigator.h"
#import "EJURouterWhiteList.h"
#import <Webkit/Webkit.h>
#import "UINavigationBar+Color.h"

@interface EJURouterWebViewController ()<WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate>
{
    WKWebView *_webView;
    
    UIButton *_closeBtn;
    
    NSMutableArray *_history;
    BOOL _backToRoot;
    BOOL _loadAboutBlank;
    WKScriptMessage *_scriptMessage;
}

@property (nonatomic, copy) NSString *leftCallBack;
@property (nonatomic, copy) NSString *rightCallBack;

@end

@implementation EJURouterWebViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_changeNaviBarColorWithSwipe == YES) {
        _webView.scrollView.delegate = self;
        //设置导航栏透明，并去掉底部横线
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar eju_reset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.hidesBackButton = YES;
    _history = [[NSMutableArray alloc]init];
    [self initWebView];
}

- (void)initWebView
{
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    //注册供js调用的方法
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    for (NSString *jsFunctionName in _jsFunctionNameArrays) {
        [userContentController addScriptMessageHandler:self name:jsFunctionName];   //注册js方法
    }
    configuration.userContentController = userContentController;
    configuration.preferences.javaScriptEnabled = YES; //打开JavaScript交互 默认为YES
    
    if (self.navigationController.navigationBar.hidden == NO) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) configuration:configuration];
    } else {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20) configuration:configuration];
    }
    [self.view addSubview:_webView];
    _webView.navigationDelegate = self;
    [self loadWithUrl:_url andParams:_params];
}

- (void)loadWithUrl:(NSURL *)url andParams:(NSDictionary *)params {
    
    __block NSMutableString *htmlString = nil;
    if ([url isFileURL]) {
        NSError *error = nil;
        htmlString = [NSMutableString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error)
            return;
        NSDictionary *dic = @{
                              @"htmlString": htmlString,
                              @"baseUrl":[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                              @"params":params
                              };
        [_history addObject:dic];
        [self loadAboutBlank];
    }
    else if ([url.absoluteString hasPrefix:@"http"] || [url.absoluteString hasPrefix:@"https"]) {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error)
                return ;
            htmlString = [[NSMutableString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dic = @{
                                  @"htmlString": htmlString,
                                  @"baseUrl":url,
                                  @"params":params
                                  };
            [_history addObject:dic];
            [self loadAboutBlank];
        }];
        [task resume];
    }
}

- (void)loadAboutBlank
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [_webView loadRequest:request];
}

- (void)loadHtmlStringWithDic:(NSDictionary *)dic
{
    NSMutableString *htmlString = dic[@"htmlString"];
    NSURL *baseUrl = dic[@"baseUrl"];
    NSDictionary *params = dic[@"params"];
    
    NSRange range = [htmlString rangeOfString:@"</head>"];
    if (range.location == NSNotFound)
    return;
    if (![NSJSONSerialization isValidJSONObject:params])
    return;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData)
    return;
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *scriptLabel = [NSString stringWithFormat:@"<script>var router_params = %@ </script>\n", jsonString];
    
    [htmlString insertString:scriptLabel atIndex:range.location-1];
    [_webView loadHTMLString:htmlString baseURL:baseUrl];
}

- (void)leftButtonClick:(UIBarButtonItem *)barButtonItem {
    
    NSLog(@"leftButtonClick");
    
    //若left的callback为空，则执行“返回”功能；若不为空，则执行native调js。
    if ([self.leftCallBack isEqualToString:@""]) {
        
        if ([_webView canGoBack]) {
            [_webView goBack];
        }
    }
    else {
        NSString *jsStr = [NSString stringWithFormat:@"%@()",self.leftCallBack];
        WKWebView *webView = (WKWebView *)_scriptMessage.webView;
        if (!webView.loading) {
            //native调js
            [webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                //TODO
                NSLog(@"response11===%@ , error11===%@",response,error);
            }];
        }
    }
    
//    if ([_webView canGoBack]) {
//        
//        [self showCloseBtn];
//        [_webView goBack];
//    } else {
//        
//        if (_history.count>1) {
//            [self showCloseBtn];
//            [_history removeLastObject];
//            [self loadHtmlStringWithDic:_history.lastObject];
//        } else {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
}

- (void)rightButtonClick:(UIBarButtonItem *)barButtonItem {
    
    NSLog(@"rightButtonClick");
    
    //若right的callback为空，则不执行任何功能；若不为空，则执行native调js。
    if (![self.rightCallBack isEqualToString:@""]) {
        
        NSString *jsStr = [NSString stringWithFormat:@"%@()",self.rightCallBack];
        WKWebView *webView = (WKWebView *)_scriptMessage.webView;
        if (!webView.loading) {
            //native调js
            [webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                //TODO
                NSLog(@"response22===%@ , error22===%@",response,error);
            }];
        }
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"name=%@, body=%@",message.name, message.body);
    _scriptMessage = message;
    
    if ([message.name isEqualToString:@"changeNaviBar"]) {     //控制导航栏左右按钮状态和标题
        
        if (![message.body isKindOfClass:[NSNull class]]) {
            self.title = [message.body objectForKey:@"title"];
            if ([[message.body objectForKey:@"left"][@"callback"] isEqualToString:@""]) {
                _leftCallBack = @"";
            }
            else {
                _leftCallBack = [message.body objectForKey:@"left"][@"callback"];
            }
            
            if ([[message.body objectForKey:@"left"][@"image"] isEqualToString:@""] || [message.body objectForKey:@"left"][@"image"] == nil) {  //导航栏左侧按钮
                
                if ([[message.body objectForKey:@"left"][@"name"] isEqualToString:@""]) {
                    self.navigationItem.leftBarButtonItem = nil;
                }
                else {
                    NSString *leftButtonTitle = [message.body objectForKey:@"left"][@"name"];
                    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:leftButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClick:)];
                    self.navigationItem.leftBarButtonItem = leftButton;
                }
            }
            else {
                NSString *leftButtonImage = [message.body objectForKey:@"left"][@"image"];
                UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [leftButton setFrame:CGRectMake(0, 0, 44, 44)];
                [leftButton setImage:[UIImage imageNamed:leftButtonImage] forState:UIControlStateNormal];
                [leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
                self.navigationItem.leftBarButtonItem = leftBarButton;
            }
            
            
            if ([[message.body objectForKey:@"right"][@"callback"] isEqualToString:@""]) {
                _rightCallBack = @"";
            }
            else {
                _rightCallBack = [message.body objectForKey:@"right"][@"callback"];
            }
            
            if ([[message.body objectForKey:@"right"][@"image"] isEqualToString:@""] || [message.body objectForKey:@"right"][@"image"] == nil) {  //导航栏右侧按钮
                
                if ([[message.body objectForKey:@"right"][@"name"] isEqualToString:@""]) {
                    self.navigationItem.rightBarButtonItem = nil;
                }
                else {
                    NSString *rightButtonTitle = [message.body objectForKey:@"right"][@"name"];
                    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonClick:)];
                    self.navigationItem.rightBarButtonItem = rightButton;
                }
            }
            else {
                
                NSString *rightButtonImage = [message.body objectForKey:@"right"][@"image"];
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [rightButton setFrame:CGRectMake(0, 0, 44, 44)];
                [rightButton setImage:[UIImage imageNamed:rightButtonImage] forState:UIControlStateNormal];
                [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
                self.navigationItem.leftBarButtonItem = rightBarButton;
            }
        }
    }
    else {      //其他
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidReceiveScriptMessage" object:message userInfo:nil];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"action");
    
    NSString *urlstr = navigationAction.request.URL.absoluteString;
    NSLog(@"urlstr=%@",urlstr);

    if (![EJURouterWhiteList isInWhiteList:urlstr]) {
        _loadAboutBlank = YES;
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    // 是否在新视图控制器中打开
    if ([[EJURouterNavigator sharedNavigator] willOpenUrlInNewPage:navigationAction.request.URL]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"start");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidStart" object:webView userInfo:nil];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"commit");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidCommit" object:webView userInfo:nil];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"finish");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidFinish" object:webView userInfo:nil];
    
    if ([webView.URL.absoluteString isEqualToString:@"about:blank"]
        && _loadAboutBlank){
        [self loadHtmlStringWithDic:_history.lastObject];
        _loadAboutBlank = NO;
    }
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidFail" object:webView userInfo:@{@"error":error}];
    NSLog(@"error===%@", error);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UIColor *color = [UIColor blackColor];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > 50) {
        CGFloat alpha = MIN(1, 1 - ((50 + 64 - offsetY) / 64));
        [self.navigationController.navigationBar eju_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
    }
    else {
        [self.navigationController.navigationBar eju_setBackgroundColor:[color colorWithAlphaComponent:0]];
    }
}

@end

//
//  EJURouterWebViewController.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "EJURouterWebViewController.h"
#import "EJURouterNavigator.h"
#import <Webkit/Webkit.h>
#import "EJURouterWhiteList.h"

@interface EJURouterWebViewController ()<WKNavigationDelegate, WKScriptMessageHandler>
{
    WKWebView *_webView;
    UIProgressView *_progressView;
    
    UIButton *_closeBtn;
    
    NSMutableArray *_history;
    BOOL _backToRoot;
    NSURL *_initialUrl;
    BOOL _loadAboutBlank;
}
@end

@implementation EJURouterWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _history = [[NSMutableArray alloc]init];
    _initialUrl = _url;
    [self addNavBtn];
    [self configUI];
}

- (void)addNavBtn {
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)configUI
{
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    //注册供js调用的方法
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    for (NSString *jsFunctionName in _jsFunctionNameArrays) {
        [userContentController addScriptMessageHandler:self name:jsFunctionName];//注册name为easyLiveShare的js方法
    }
    configuration.userContentController = userContentController;
    configuration.preferences.javaScriptEnabled = YES; //打开JavaScript交互 默认为YES

    
    if (self.navigationController.navigationBar.hidden == NO) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 0)];
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) configuration:configuration];
     } else {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 0)];
         _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20) configuration:configuration];
    }
    _progressView.progress = 0;
    _progressView.progressTintColor = [UIColor greenColor];
    _progressView.trackTintColor = [UIColor clearColor];
    
    [self.view addSubview:_webView];
    [self.view addSubview:_progressView];
    
    _webView.navigationDelegate = self;
    [self loadWithUrl:_url andParams:_params];
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
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
    } else if ([url.absoluteString hasPrefix:@"http"]) {
        
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

- (void)loadRequest
{
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
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

- (void)showCloseBtn
{
    if (self.navigationItem.leftBarButtonItems.count==1) {
        _progressView.progress = 0;
        UIBarButtonItem *close = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
        self.navigationItem.leftBarButtonItems = @[self.navigationItem.leftBarButtonItems[0], close];
    }
}

- (void)back {
    if ([_webView canGoBack]) {
        
        [self showCloseBtn];
        [_webView goBack];
    } else {
//        if (!_backToRoot && _url != _initialUrl) {
//            [self showCloseBtn];
//            [self firstLoadWithUrl:_initialUrl];
//            _backToRoot = YES;
//        } else {
//        }
        if (_history.count>1) {
            [self showCloseBtn];
            [_history removeLastObject];
            [self loadHtmlStringWithDic:_history.lastObject];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [_progressView setProgress:[change[@"new"] floatValue] animated:YES];
    if ([change[@"new"] floatValue] == 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _progressView.progress = 0.0;
        });
    }
}

- (void)dealloc
{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

//- (void)setUrl:(NSURL *)url
//{
//    _url = url;
//    if (_url) {
//        [self loadRequest];
//    }
//}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidReceiveScriptMessage" object:message userInfo:nil];
}

#pragma mark - NavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"action");
    NSString *urlstr = navigationAction.request.URL.absoluteString;
    if (![EJURouterWhiteList isInWhiteList:urlstr]) {
        _loadAboutBlank = YES;
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
//    if ([urlstr isEqualToString:@"about:blank"] || [urlstr isEqualToString:_url.absoluteString]) {
//        decisionHandler(WKNavigationActionPolicyAllow);
//        return;
//    }
    
    
//    _progressView.progress = 0;
    // 是否在新视图控制器中打开
    if ([[EJURouterNavigator sharedNavigator]willOpenUrlInNewPage:navigationAction.request.URL]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"start");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidStart" object:webView userInfo:nil];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"commit");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidCommit" object:webView userInfo:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"finish");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidFinish" object:webView userInfo:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _progressView.progress = 0.0;
    });
    
    if ([webView.URL.absoluteString isEqualToString:@"about:blank"]
        && _loadAboutBlank){
        [self loadHtmlStringWithDic:_history.lastObject];
        _loadAboutBlank = NO;
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewDidFail" object:webView userInfo:@{@"error":error}];
    NSLog(@"%@", error);
}

@end

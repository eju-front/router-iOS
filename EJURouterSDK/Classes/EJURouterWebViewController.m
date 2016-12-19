//
//  EJURouterWebViewController.m
//  Pods
//
//  Created by 施澍 on 2016/11/25.
//
//

#import "EJURouterWebViewController.h"
#import "EJURouterNavigator.h"
#import <Webkit/Webkit.h>

@interface EJURouterWebViewController ()<WKNavigationDelegate>
{
    WKWebView *_webView;
    UIProgressView *_progressView;
    
    UIButton *_closeBtn;
}
@end

@implementation EJURouterWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addNavBtn];
    [self configUI];
}

- (void)addNavBtn {
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)back {
    if ([_webView canGoBack]) {
        
        if (self.navigationItem.leftBarButtonItems.count==1) {
            _progressView.progress = 0;
            UIBarButtonItem *close = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
            self.navigationItem.leftBarButtonItems = @[self.navigationItem.leftBarButtonItems[0], close];
        }
        [_webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configUI
{
    if (self.navigationController) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 0)];
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    } else {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 0)];
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    }
    _progressView.progress = 0;
    _progressView.progressTintColor = [UIColor greenColor];
    _progressView.trackTintColor = [UIColor clearColor];
    
    [self.view addSubview:_webView];
    [self.view addSubview:_progressView];
    
    _webView.navigationDelegate = self;
    if (_url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [_webView loadRequest:request];
    }
    
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [_progressView setProgress:[change[@"new"] floatValue] animated:YES];
    NSLog(@"%@",change[@"new"]);
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

- (void)setUrl:(NSURL *)url {
    _url = url;
    if (_url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [_webView loadRequest:request];
    }
}

#pragma mark - NavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"action");
    
    if ([navigationAction.request.URL.absoluteString isEqualToString:self.url.absoluteString]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
//    _progressView.progress = 0;
    // 是否在新视图控制器中打开
    if ([[EJURouterNavigator sharedNavigator]willOpenUrlInNewPage:navigationAction.request.URL]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"commit");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"finish");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _progressView.progress = 0.0;
    });
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@", error);
}

@end

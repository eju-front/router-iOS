//
//  EJUNavigator.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "EJURouterNavigator.h"
#import "EJURouterWebViewController.h"
#import "EJURouterVCMap.h"
#import "EJURouterObject.h"
#import "EJURouterNotFoundViewController.h"
#import "EJURouterSDK.h"
#import "EJURouterHelper.h"

NSString *EJURouterIdKey                = @"router_id";
NSString *EJURouterParamsKey            = @"parameters";
static EJURouterNavigator *_navigator   = nil;

@implementation EJURouterNavigator

#pragma mark - SharedInstance
+ (instancetype)sharedNavigator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_navigator) {
            _navigator = [[self alloc]init];
        }
    });
    return _navigator;
}

- (EJURouterConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[EJURouterConfiguration alloc]init];
    }
    return _configuration;
}

#pragma mark - Push
- (void) openId:(NSString *)identifier
jsFunctionArray:(NSArray *)jsFunctionArray
   onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:NO
        isFromSB:NO
          sbName:nil
            sbId:nil
          params:nil
          isPush:YES
          fromVC:nil
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

- (void) openId:(NSString *)identifier
         params:(NSDictionary *)params
jsFunctionArray:(NSArray *)jsFunctionArray
   onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:NO
        isFromSB:NO
          sbName:nil
            sbId:nil
          params:params
          isPush:YES
          fromVC:nil
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

- (void)openFromXibWithId:(NSString *)identifier
                   params:(NSDictionary *)params
          jsFunctionArray:(NSArray *)jsFunctionArray
             onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:YES
        isFromSB:NO
          sbName:nil
            sbId:nil
          params:params
          isPush:YES
          fromVC:nil
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

- (void)openFromStoryboardWithId:(NSString *)identifier
                          sbName:(NSString *)sbName
                            sbId:(NSString *)sbId
                          params:(NSDictionary *)params
                 jsFunctionArray:(NSArray *)jsFunctionArray
                    onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:NO
        isFromSB:YES
          sbName:sbName
            sbId:sbId
          params:params
          isPush:YES
          fromVC:nil
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

#pragma mark - Present

- (void)presentId:(NSString *)identifier
             from:(UIViewController *)fromVC
           params:(NSDictionary *)params
  jsFunctionArray:(NSArray *)jsFunctionArray
     onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:NO
        isFromSB:NO
          sbName:nil
            sbId:nil
          params:params
          isPush:NO
          fromVC:fromVC
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

- (void)presentXibWithId:(NSString *)identifier
                    from:(UIViewController *)fromVC
                  params:(NSDictionary *)params
         jsFunctionArray:(NSArray *)jsFunctionArray
            onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:YES
        isFromSB:NO
          sbName:nil
            sbId:nil
          params:params
          isPush:NO
          fromVC:fromVC
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

- (void)presentSBWithId:(NSString *)identifier
                 sbName:(NSString *)sbName
                   sbId:(NSString *)sbId
                   from:(UIViewController *)fromVC
                 params:(NSDictionary *)params
        jsFunctionArray:(NSArray *)jsFunctionArray
           onCompletion:(EJURouterCompletionBlock)completion
{
    [self openId:identifier
       isFromXib:NO
        isFromSB:YES
          sbName:sbName
            sbId:sbId
          params:params
          isPush:NO
          fromVC:fromVC
 jsFunctionArray:jsFunctionArray
    onCompletion:completion];
}

#pragma mark - OriginMethod

- (void) openId:(NSString *)identifier
      isFromXib:(BOOL)isFromXib
       isFromSB:(BOOL)isFromSB
         sbName:(NSString *)sbName
           sbId:(NSString *)sbId
         params:(NSDictionary *)params
         isPush:(BOOL)isPush
         fromVC:(UIViewController *)fromVC
jsFunctionArray:(NSArray *)jsFunctionArray
   onCompletion:(EJURouterCompletionBlock)completion
{
    NSUInteger resultCode = EJURouterResponseStatusCodeUnknownError;
    UIViewController *vc = nil;
    
    @try {
        EJURouterDataModel *model = [self.map modelWithIdentifier:identifier];
        if (!model) {
            NSException *exception = [NSException exceptionWithName:@"NotFound" reason:@"PageNotFound" userInfo:@{@"code":@(EJURouterResponseStatusCodePageNotFound)}];
            @throw exception;
        }
        
        //根据identifier寻找ViewClass
        Class VCClass = NSClassFromString(model.className);
        if (!VCClass) {
            NSException *exception = [NSException exceptionWithName:@"NotFound" reason:@"PageNotFound" userInfo:@{@"code":@(EJURouterResponseStatusCodePageNotFound)}];
            @throw exception;
        }
        
        //创建vc
        if (isFromXib) {                    // xib
            vc = [(UIViewController *)[VCClass alloc]initWithNibName:NSStringFromClass(VCClass) bundle:[NSBundle mainBundle]];
        } else if (isFromSB) {              // sb
            UIStoryboard *sb = [UIStoryboard storyboardWithName:sbName bundle:[NSBundle mainBundle]];
            vc = [sb instantiateViewControllerWithIdentifier:sbId];
        } else {                            // class
            vc = [[VCClass alloc]init];
        }
        
        //属性赋值
        [self configVC:vc WithDataModel:model params:params jsFunctionArray:jsFunctionArray];
        
        if (isPush) {           //推页面
            if ([self.navigationController isKindOfClass:[UINavigationController class]]) {
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else if(fromVC) {     //模态化弹出
            [fromVC presentViewController:vc animated:YES completion:nil];
        }
        
        //成功
        resultCode = EJURouterResponseStatusCodeSuccess;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
        if ([exception.name isEqualToString:NSInvalidArgumentException]) {
            resultCode = EJURouterResponseStatusCodeWrongParameter;
        }
        else if ([exception.name isEqualToString:@"NotFound"]) {
            // 404
            resultCode = EJURouterResponseStatusCodePageNotFound;
            [self gotoNotFoundPageWithFromVC:fromVC];
        }
        else {
            resultCode = EJURouterResponseStatusCodeUnknownError;
        }
    } @finally {
        // 完成回调
        if (completion) {
            completion(vc, resultCode);
        }
    }
}

#pragma mark - Not Found Page
- (void)gotoNotFoundPageWithFromVC:(id)fromVC {
    id notfoundVc = self.configuration.notFoundPageClass ? [[self.configuration.notFoundPageClass alloc]init] : [[EJURouterNotFoundViewController alloc]init];
    fromVC ? [fromVC presentViewController:notfoundVc animated:YES completion:nil] : [self.navigationController pushViewController:notfoundVc animated:YES];
}

#pragma mark - ConfigVC

- (void)configVC:(UIViewController *)vc WithDataModel:(EJURouterDataModel *)model params:(NSDictionary *)params jsFunctionArray:(NSMutableArray *)jsFunctionArray
{
    switch (model.type) {
        case EJURouterPageTypeNative:
        {
            [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *setMethod = [NSString stringWithFormat:@"set%@:",[key capitalizedString]];
                if ([vc respondsToSelector:NSSelectorFromString(setMethod)]) {
                    [vc setValue:obj forKey:key];
                }
            }];
            break;
        }
        case EJURouterPageTypeLocalHtml:
        {
            NSString *filePath = [[NSBundle mainBundle]pathForResource:model.resource ofType:nil];
            if (!filePath)
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"cannot find file named %@", model.resource] userInfo:nil];
            
            NSURL *url = [EJURouterHelper getUrlFromResource:filePath];
            if (!url)
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil url" userInfo:nil];
            [(EJURouterWebViewController *)vc setUrl:url];
            [(EJURouterWebViewController *)vc setParams:params];
            [(EJURouterWebViewController *)vc setJsFunctionNameArrays:jsFunctionArray];
            break;
        }
        case EJURouterPageTypeWeb:
        {
            // 拼接url
            NSURL *url = [EJURouterHelper getUrlFromResource:model.resource];
            if (!url)
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil url" userInfo:nil];
            [(EJURouterWebViewController *)vc setUrl:url];
            [(EJURouterWebViewController *)vc setParams:params];
            [(EJURouterWebViewController *)vc setJsFunctionNameArrays:jsFunctionArray];
            break;
        }
        default:
            break;
    }
    
    vc.title = model.description;
}

#pragma mark - find
- (EJURouterDataModel *)findVcWithId:(NSString *)identifier
{
    return [self.map modelWithIdentifier:identifier];
}

- (BOOL)openApp:(NSURL *)url
{
    UIApplication *application = [UIApplication sharedApplication];
    BOOL result = [application canOpenURL:url];
    if (result) {
        [application openURL:url];
    }
    return result;
}

#pragma mark - Open Url(从h5页面打开页面)
- (BOOL)willOpenUrlInNewPage:(NSURL *)url
{
    if (url) {
        if ([url.scheme hasPrefix:@"http"]) {
            return NO;
        } else if (![url.scheme isEqualToString:self.configuration.urlScheme]) {
            
            return [self openApp:url];
        }
        
        //参数
        NSMutableDictionary *params = [EJURouterHelper serilizeUrlQuery:url.query];
        
        //id
        NSString *identifier            = params[EJURouterIdKey];
        [params removeObjectForKey:EJURouterIdKey];
        
        EJURouterDataModel *model       = [self.map modelWithIdentifier:identifier];
        
        if (model.type == EJURouterPageTypeNative) {
            //本地
            // 打开页面
            if ([[NSBundle mainBundle] pathForResource:model.className ofType:@"nib"]) {    //xib
                [self openFromXibWithId:identifier params:params jsFunctionArray:@[] onCompletion:nil];
            }
            else if ([[NSBundle mainBundle] pathForResource:model.className ofType:@"storyboardc"]) {      //storyboard
                [self openFromStoryboardWithId:identifier sbName:@"" sbId:@"" params:params jsFunctionArray:@[] onCompletion:nil];
            }
            else {      //vc
                
                [self openId:identifier params:params jsFunctionArray:@[] onCompletion:nil];
            }
            return YES;
            // local html
        } else if (model.type == EJURouterPageTypeLocalHtml) {
            NSString *filePath = [[NSBundle mainBundle]pathForResource:model.resource ofType:nil];
            if (filePath) {
                NSURL *relativeUrl = [NSURL fileURLWithPath:filePath];
                NSDictionary *params = [EJURouterHelper serilizeUrlQuery:url.query];
                [self openWebVcWithUrl:relativeUrl andParams:params andJSFunctionArray:@[]];
                return NO;
            } else {
                [self gotoNotFoundPageWithFromVC:nil];
                return YES;
            }
        }
    }
    return NO;
}

- (void)openWebVcWithUrl:(NSURL *)url andParams:(NSDictionary *)params andJSFunctionArray:(NSArray *)jsFunctionArray {
    EJURouterWebViewController *webVc = self.navigationController.topViewController;
    if ([webVc isKindOfClass:[EJURouterWebViewController class]]) {
        [webVc setUrl:url];
        [webVc setParams:params];
        [webVc setJsFunctionNameArrays:jsFunctionArray];
        [webVc loadWithUrl:url andParams:params];
    }
}

@end

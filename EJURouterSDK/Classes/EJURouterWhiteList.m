//
//  EJURouterWhiteList.m
//  Pods
//
//  Created by 施澍 on 2016/12/28.
//
//

#import "EJURouterWhiteList.h"
#import "EJURouterNavigator.h"
#import "EJURouterSDK.h"

@implementation EJURouterWhiteList
+ (BOOL)isInWhiteList:(NSString *)urlStr
{
    NSString *http = @"http://127.0.0.1:8020";
    NSString *app = [NSString stringWithFormat:@"%@://%@", [EJURouterNavigator sharedNavigator].configuration.urlScheme,[EJURouterNavigator sharedNavigator].configuration.urlHost];
    
    return [urlStr hasPrefix:http] || [urlStr hasPrefix:app];
}
@end

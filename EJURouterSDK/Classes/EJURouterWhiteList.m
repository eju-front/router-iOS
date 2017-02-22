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
    NSString *http = @"http://10.0.60.95:8090";
    NSString *app = [NSString stringWithFormat:@"%@://", [EJURouterNavigator sharedNavigator].configuration.urlScheme];
    
    return [urlStr hasPrefix:http] || [urlStr hasPrefix:app];
}
@end

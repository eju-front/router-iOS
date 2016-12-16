//
//  EJURouterMapUpdater.m
//  Pods
//
//  Created by 施澍 on 2016/11/29.
//
//

#import "EJURouterMapUpdater.h"
#import "EJURouterNavigator.h"
#import "EJURouterSDK.h"
#import "EJURouterVCMap.h"
#import "EJURouterHelper.h"

@implementation EJURouterMapUpdater

+ (void)updateMap
{
    EJURouterConfiguration *config = [EJURouterNavigator sharedNavigator].configuration;
    
    if (config.updateRequest) {
        [self startRequestWithRequest:config.updateRequest completionBlock:^(NSData *data) {
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                EJURouterVCMap *map = [EJURouterNavigator sharedNavigator].map;
                // 匹对version
                NSString *localVersion = map.version;
                NSString *onlineVersion = responseDic[@"version"];
                
                if ([localVersion compare:onlineVersion] == NSOrderedAscending) {
                    NSString *onlineMd5 = responseDic[@"md5"];
                    NSString *downloadUrlStr = responseDic[@"downloadUrl"];
                    
                    NSURL *url = [NSURL URLWithString:downloadUrlStr];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    [self startRequestWithRequest:request completionBlock:^(NSData *data) {
                        NSString *localMd5 = [EJURouterHelper fileHashWithData:data];
                        if ([localMd5 isEqualToString:onlineMd5]) {
                            if (data) {
                                @try {
                                    [data writeToFile:map.downloadPath atomically:YES];
                                } @catch (NSException *exception) {
                                    NSFileManager *fm = [NSFileManager defaultManager];
                                    [fm removeItemAtPath:map.downloadPath error:nil];
                                }
                            }
                        }
                    }];
                }
        }];
    }
}

+ (void)startRequestWithRequest:(NSURLRequest *)request completionBlock:(void (^)(NSData *data))success
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                success(data);
            } else {
                success(nil);
            }
        });
    }];
    [task resume];
}

@end

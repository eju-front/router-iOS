//
//  EJURouterURLHelper.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#pragma GCC diagnostic ignored "-Wselector"

#include <CommonCrypto/CommonDigest.h>

#import <Availability.h>
#import "EJURouterHelper.h"
#import "EJURouterSDKDefine.h"

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif


@implementation EJURouterHelper

+ (NSURL *)getUrlFromResource:(NSString *)resource
{
    if (!resource.length)
        return nil;
//    resource = [resource stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *relativeUrl = [resource hasPrefix:@"http"] || [resource hasPrefix:@"https"]?[NSURL URLWithString:resource]:[NSURL fileURLWithPath:resource];
    return relativeUrl;
}

+ (NSURL *)appendUrlStr:(NSString *)urlStr withparams:(NSDictionary *)params
{
    NSURL *relativeUrl = [self getUrlFromResource:urlStr];
    if (!relativeUrl)
        return nil;
    
    NSMutableString *paramsStr = [NSMutableString string];
    if (![params isKindOfClass:[NSDictionary class]]) {
        return relativeUrl;
    }
    
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 忽略key不是string类型的参数
        if ([key isKindOfClass:[NSString class]]) {
            NSString *value;
            //判断obj类型
            if ([NSJSONSerialization isValidJSONObject:obj]) {      //字典或数组
                NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
                value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            } else {       //字符串
                value = obj;
            }
            
            [paramsStr appendFormat:@"&%@=%@", key, value];
        }
    }];
    
    if (paramsStr.length) {
        [paramsStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
        paramsStr = [paramsStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        relativeUrl = [NSURL URLWithString:paramsStr relativeToURL:relativeUrl];
    }
    return relativeUrl;
}

+ (NSMutableDictionary *)serilizeUrlQuery:(NSString *)query
{
    query = [query stringByRemovingPercentEncoding];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    for (NSString *str in components) {
        NSArray *keyvalue = [str componentsSeparatedByString:@"="];
        if (keyvalue.count>1) {
            NSString *value = keyvalue[1];
            NSString *key = keyvalue[0];
            //参数可能为json
            @try {
                NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                jsonData?[params setValue:jsonData forKey:key]:[params setValue:value forKey:key];
            } @catch (NSException *exception) {
                [params setValue:value forKey:key];
            }
        }
    }
    
    NSDictionary *otherParams = params[EJURouterParamsKey];
    if (otherParams) {
        [params removeObjectForKey:EJURouterParamsKey];
        [params addEntriesFromDictionary:otherParams];
    }
    
    return params;
}

+ (NSString *)appUrlScheme
{
    NSString * urlScheme        = nil;
    NSArray * schemes           = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    
    for (NSDictionary * scheme in schemes) {
        NSString * identifier   = [scheme objectForKey:@"CFBundleURLName"];
        NSArray * items     = [scheme objectForKey:@"CFBundleURLSchemes"];
        if (items && items.count) {
            urlScheme       = [items objectAtIndex:0];
        }
    }
    
    return urlScheme;
}

+ (NSString *)fileHashWithData:(NSData *)fileData
{
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    //    CFURLRef fileURL =
    //    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
    //                                  (CFStringRef)filePath,
    //                                  kCFURLPOSIXPathStyle,
    //                                  (Boolean)false);
    //    if (!fileURL) goto done;
    
    // Create and open the read stream
    //    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
    //                                            (CFURLRef)fileURL);
    readStream = CFReadStreamCreateWithBytesNoCopy(kCFAllocatorDefault, [fileData bytes], fileData.length, kCFAllocatorNull);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[4096];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                           (const char *)hash,
                                           kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    
    return (__bridge NSString *)(result);
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end

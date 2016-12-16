//
//  EJURouterURLHelper.m
//  Pods
//
//  Created by 施澍 on 2016/12/6.
//
//

#pragma GCC diagnostic ignored "-Wselector"

#include <CommonCrypto/CommonDigest.h>

#import <Availability.h>
#import "EJURouterHelper.h"

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif


@implementation EJURouterHelper

+ (NSURL *)appendUrlStr:(NSString *)urlStr withparams:(NSDictionary *)params
{
    if (!urlStr.length)
        return nil;
    
    NSURL *relativeUrl = [urlStr hasPrefix:@"http"]?[NSURL URLWithString:urlStr]:[NSURL fileURLWithPath:urlStr];
    
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

+ (NSDictionary *)serilizeUrlQuery:(NSString *)query {
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

+ (NSString *)fileHashWithData:(NSData *)fileData {
    
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

@end

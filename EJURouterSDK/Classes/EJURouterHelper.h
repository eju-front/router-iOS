//
//  EJURouterURLHelper.h
//  Pods
//
//  Created by 施澍 on 2016/12/6.
//
//

#import <Foundation/Foundation.h>

@interface EJURouterHelper : NSObject

/**
 拼接URL参数

 @param urlStr url
 @param params 参数

 @return 带参数url
 */
+ (NSURL *)appendUrlStr:(NSString *)urlStr withparams:(NSDictionary *)params;

/**
 序列化url中的参数

 @param query 参数
 
 @return 字典
 */
+ (NSDictionary *)serilizeUrlQuery:(NSString *)query;


/**
 获取URL Scheme

 @return URL Scheme中第0条
 */
+ (NSString *)appUrlScheme;


/**
 文件md5

 @param fileData 文件数据

 @return md5串
 */
+ (NSString *)fileHashWithData:(NSData *)fileData;

@end

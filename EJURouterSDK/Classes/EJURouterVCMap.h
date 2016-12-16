//
//  EJUVCMap.h
//  Pods
//
//  Created by 施澍 on 2016/11/25.
//
//

#import <Foundation/Foundation.h>

@class EJURouterDataModel;
@interface EJURouterVCMap : NSObject

@property (nonatomic, readonly) NSDictionary    *vcMap;
@property (nonatomic, strong)   NSString        *version;
@property (nonatomic, readonly) NSString        *downloadPath;

- (void)readVCMap;
- (EJURouterDataModel *)modelWithIdentifier:(NSString *)identifier;

@end

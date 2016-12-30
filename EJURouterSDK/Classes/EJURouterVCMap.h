//
//  EJUVCMap.h
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
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

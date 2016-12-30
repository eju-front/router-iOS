//
//  EJURouterObject.h
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EJURouterSDKDefine.h"

@interface EJURouterDataModel : NSObject

@property (nonatomic, copy)   NSString          *className;
@property (nonatomic, copy)   NSString          *identifier;
@property (nonatomic, copy)   NSString          *resource;
@property (nonatomic, assign) EJURouterPageType type;
@property (nonatomic, copy)   NSString          *description;

@end

//
//  EJURouterObject.h
//  Pods
//
//  Created by 施澍 on 2016/11/25.
//
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

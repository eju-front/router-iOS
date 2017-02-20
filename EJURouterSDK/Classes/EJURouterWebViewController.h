//
//  EJURouterWebViewController.h
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EJURouterWebViewController : UIViewController

@property (nonatomic, strong) NSURL          *url;
@property (nonatomic, copy)   NSDictionary   *params;
@property (nonatomic, strong) NSArray *jsFunctionNameArrays;     //js方法名 数组

- (void)loadWithUrl:(NSURL *)url andParams:(NSDictionary *)params;

@end

//
//  EJU_ROUTER_ViewController.m
//  EJURouterSDK
//
//  Created by seth on 11/25/2016.
//  Copyright (c) 2016 seth. All rights reserved.
//

#import "EJU_ROUTER_ViewController.h"
#import <EJURouterSDK/EJURouterNavigator.h>

@interface EJU_ROUTER_ViewController ()

@end

@implementation EJU_ROUTER_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"测试";
    [EJURouterNavigator sharedNavigator].navigationController = self.navigationController;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.row) {
        case 0:
        {
            NSDictionary *params = @{
                                        @"name":@"老王",
                                        @"age":@"29",
                                        @"height":@100,
                                        @"children":@[@"大王", @"小王"],
                                        @"birthday":[NSDate date]
                                     };
            // native
            [[EJURouterNavigator sharedNavigator]openId:@"native" params:params onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
                NSLog(@"+++%ld", resultCode);
            }];
            break;
        }
        case 1:
        {
            // local html
            NSDictionary *params = @{
                                     @"name":@"老王",
                                     @"age":@"29",
                                     @"height":@100,
                                     @"children":@[@"大王", @"小王"],
                                     };
            [[EJURouterNavigator sharedNavigator]openId:@"localhtml1" params:params onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
                NSLog(@"+++%ld", resultCode);
            }];
            break;
        }
        case 2:
        {
//            NSDictionary *params = @{
//                                     @"name":@"老王",
//                                     @"age":@"29",
//                                     @"height":@100,
//                                     @"children":@[@"大王", @"小王"],
//                                     };
            
            NSDictionary *params = @{
                                     @"userId":@"6"
                                     };
            // web
            [[EJURouterNavigator sharedNavigator]openId:@"web" params:params onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
                NSLog(@"+++%ld", resultCode);
            }];
            break;
        }
        case 3:
            [[EJURouterNavigator sharedNavigator]openId:@"123" onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
                NSLog(@"+++%ld", resultCode);
            }];
            break;
        default:
            break;
    }
}

@end

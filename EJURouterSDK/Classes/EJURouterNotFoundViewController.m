//
//  EJURouterNotFoundViewController.m
//  Pods
//
//  Created by Seth on 11/25/2016.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "EJURouterNotFoundViewController.h"

@interface EJURouterNotFoundViewController ()

@end

@implementation EJURouterNotFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"404";
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:self.view.bounds];
    lbl.font = [UIFont systemFontOfSize:40];
    lbl.text = @"NOT FOUND";
    lbl.textAlignment = 1;
    [self.view addSubview:lbl];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

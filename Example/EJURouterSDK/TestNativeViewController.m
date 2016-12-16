//
//  EJU_ROUTER_TestNativeViewController.m
//  EJURouterSDK
//
//  Created by 施澍 on 2016/11/30.
//  Copyright © 2016年 seth. All rights reserved.
//

#import "TestNativeViewController.h"
#import <objc/message.h>

@interface TestNativeViewController ()

@end

@implementation TestNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
        
    [self showRecievedParams];
    
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList(self.class, &count);
    for (int i = 0; i<count; i++) {
        objc_property_t property = list[i];
        printf("%s {\n", property_getName(property));
        
        unsigned outCount = 0;
        objc_property_attribute_t *attList = property_copyAttributeList(property, &outCount);
        for (int j = 0; j<outCount; j++) {
            objc_property_attribute_t att = attList[j];
            printf("%s=%s  ", att.name, att.value);
        }
        printf("\n}\n");
    }
}

- (void)showRecievedParams {
    UITextView *txtView= [[UITextView alloc]initWithFrame:self.view.frame];
    txtView.font = [UIFont systemFontOfSize:20];
    txtView.editable = NO;
    txtView.selectable = NO;
    [self.view addSubview:txtView];
    
    NSMutableDictionary *dic = @{}.mutableCopy;
    if (_name) {
        [dic setValue:_name forKey:@"name"];
    }
    [dic setValue:@(_age) forKey:@"age"];
    if (_height) {
        [dic setValue:_height forKey:@"height"];
    }
    if (_children) {
        [dic setValue:_children forKey:@"_children"];
    }
    if (_birthday) {
        [dic setValue:[NSString stringWithFormat:@"%@",_birthday] forKey:@"birthday"];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    txtView.text = [NSString stringWithFormat:@"接收到参数：\n%@", str];
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

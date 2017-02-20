//
//  EJU_ROUTER_UnitTest.m
//  EJURouterSDK
//
//  Created by 施澍 on 2016/12/6.
//  Copyright © 2016年 seth. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <EJURouterSDK/EJURouterSDK.h>
#import <EJURouterSDK/EJURouterNavigator.h>
#import <EJURouterSDK/EJURouterSDKDefine.h>
#import <EJURouterSDK/EJURouterVCMap.h>
#import <EJURouterSDK/EJURouterHelper.h>

@interface EJU_ROUTER_UnitTest : XCTestCase

@end

@implementation EJU_ROUTER_UnitTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // 初始化
    [EJURouterSDK startServiceWithConfiguration:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // 单例是否初始化成功
    XCTAssertNotNil([EJURouterNavigator sharedNavigator], @"单例初始化失败！");
    
    // 配置表是否读取成功
    EJURouterVCMap *map = [[EJURouterVCMap alloc]init];
    [map readVCMap];
    XCTAssertNotNil(map.vcMap, @"配置表读取失败！");
    
    // 匹配项
    XCTAssertNotNil([map modelWithIdentifier:@"native"], @"匹配id失败！");
    XCTAssertNotNil([map modelWithIdentifier:@"localhtml1"], @"匹配id失败！");
    XCTAssertNotNil([map modelWithIdentifier:@"localhtml2"], @"匹配id失败！");
    XCTAssertNotNil([map modelWithIdentifier:@"web"], @"匹配id失败！");
    
    // url拼接
    XCTAssertNotNil([EJURouterHelper appendUrlStr:@"http://www.baidu.com" withparams:@{@"name":@"老王"}], @"参数拼接有误！");
    XCTAssertEqualObjects([EJURouterHelper appendUrlStr:nil withparams:nil], nil);
    XCTAssertEqualObjects([EJURouterHelper appendUrlStr:nil withparams:@{@"name":@"John"}], nil);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    XCTAssertEqualObjects([[EJURouterHelper appendUrlStr:@"http://www.baidu.com" withparams:@[]] absoluteString], @"http://www.baidu.com");
#pragma clang diagnostic pop
    XCTAssertEqualObjects([[EJURouterHelper appendUrlStr:@"http://www.baidu.com" withparams:nil] absoluteString], @"http://www.baidu.com");
    XCTAssertEqualObjects([[EJURouterHelper appendUrlStr:@"http://www.baidu.com" withparams:@{@"name":@"John"}] absoluteString], @"http://www.baidu.com?name=John");

    
    // 序列化参数
    NSDictionary *query = [EJURouterHelper serilizeUrlQuery:@"name=John&age=10&children=[\"Tom\",\"Bob\"]"];
    XCTAssertEqualObjects(query[@"name"], @"John");
    XCTAssertEqualObjects(query[@"age"], @"10");
    XCTAssertEqualObjects(query[@"children"][0], @"Tom");
    
    XCTAssertEqualObjects([EJURouterHelper serilizeUrlQuery:@"name=John"][@"name"], @"John");
    XCTAssertEqualObjects([EJURouterHelper serilizeUrlQuery:@"name=John&"][@"name"], @"John");
    XCTAssertEqualObjects([EJURouterHelper serilizeUrlQuery:@"name=John&sss"][@"name"], @"John");
    XCTAssertEqual([EJURouterHelper serilizeUrlQuery:nil].allKeys.count, 0);
    
    NSArray *jsFunctionArray = @[@"easyLiveShare"];
    
    [[EJURouterNavigator sharedNavigator]openId:@"native" jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        XCTAssertEqual(resultCode, EJURouterResponseStatusCodeSuccess);
    }];
    
    [[EJURouterNavigator sharedNavigator]openId:@"localhtml1" jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        XCTAssertEqual(resultCode, EJURouterResponseStatusCodeSuccess);
    }];
    
    [[EJURouterNavigator sharedNavigator]openId:@"web" jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        XCTAssertEqual(resultCode, EJURouterResponseStatusCodeSuccess);
    }];
    
    [[EJURouterNavigator sharedNavigator]openId:@"notfoundthispage" jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        XCTAssertEqual(resultCode, EJURouterResponseStatusCodePageNotFound);
    }];
    
    NSDictionary *dic = @{
                             @"name":@"老王",
                             @"age":@"29",
                             @"height":@100,
                             @"children":@[@"大王", @"小王"],
                             @"birthday":[NSDate date]
                             };
    [[EJURouterNavigator sharedNavigator]openId:@"native" params:dic jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        XCTAssertEqualObjects([vc valueForKey:@"name"], @"老王");
        XCTAssertEqualObjects([vc valueForKey:@"age"], @29);
        XCTAssertEqualObjects([vc valueForKey:@"height"], @100);
        XCTAssertEqualObjects([vc valueForKey:@"children"][0], @"大王");
        XCTAssertEqual(resultCode, EJURouterResponseStatusCodeSuccess);
    }];
    
    [[EJURouterNavigator sharedNavigator]presentId:@"native" from:nil params:dic jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        XCTAssertEqualObjects([vc valueForKey:@"name"], @"老王");
        XCTAssertEqualObjects([vc valueForKey:@"age"], @29);
        XCTAssertEqualObjects([vc valueForKey:@"height"], @100);
        XCTAssertEqualObjects([vc valueForKey:@"children"][0], @"大王");
        XCTAssertEqual(resultCode, EJURouterResponseStatusCodeSuccess);
    }];
    
    [[EJURouterNavigator sharedNavigator]presentXibWithId:@"native" from:nil params:dic jsFunctionArray:jsFunctionArray onCompletion:^(UIViewController *vc, EJURouterResponseStatusCode resultCode) {
        NSLog(@"1234");
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

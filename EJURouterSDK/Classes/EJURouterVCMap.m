//
//  EJUVCMap.m
//  Pods
//
//  Created by 施澍 on 2016/11/25.
//
//

#import "EJURouterVCMap.h"
#import "EJURouterObject.h"

@implementation EJURouterVCMap

- (instancetype)init
{
    if (self = [super init]) {
        _vcMap = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (NSString *)downloadPath
{
    return [NSHomeDirectory() stringByAppendingString:@"/Documents/vcmap.plist"];
}

- (void)readVCMap
{
    NSArray *mapArray = nil;
    @try {
        NSString *downloadPath = self.downloadPath;
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:downloadPath]) {
            mapArray = [[NSArray alloc]initWithContentsOfFile:downloadPath];
            if (!mapArray) {
                NSException *excp = [NSException exceptionWithName:@"ReadMapError" reason:@"read plist file error" userInfo:nil];
                @throw excp;
            }
        } else {
            NSString *inProjPath = [[NSBundle mainBundle]pathForResource:@"vcmap.plist" ofType:nil];
            mapArray = [[NSArray alloc]initWithContentsOfFile:inProjPath];
        }
    } @catch (NSException *exception) {
        NSString *inProjPath = [[NSBundle mainBundle]pathForResource:@"vcmap.plist" ofType:nil];
        mapArray = [[NSArray alloc]initWithContentsOfFile:inProjPath];
    } @finally {
        [(NSMutableDictionary *)_vcMap removeAllObjects];
        for (NSDictionary *dic in mapArray) {
            if ([dic isKindOfClass:[NSDictionary class]]) {
                EJURouterDataModel *model = [[EJURouterDataModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [_vcMap setValue:model forKey:model.identifier];
            } else {
                self.version = (NSString *)dic;
            }
        }
    }
}

- (EJURouterDataModel *)modelWithIdentifier:(NSString *)identifier
{
    return _vcMap[identifier];
}

@end

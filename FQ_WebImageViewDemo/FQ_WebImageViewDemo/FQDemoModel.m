//
//  AppDelegate.h
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "FQDemoModel.h"

@implementation FQDemoModel

+ (instancetype)appWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}
/**
 *  返回所有应用信息
 *
 */
+(NSArray *)apps {
    // 获得文件的全路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil];
    // 加载应用信息
    NSArray *appArray = [NSArray arrayWithContentsOfFile:filePath];
    
    // 创建模型数组
    //Capacity:容量 在创建数组的同时指定数组的容量.比如是10
    // 那么系统就会在创建数组的时候分配10个内存空间. 如果添加第11个元素,则会再分配10个内存空间.
    // [NSMutableArray array]:创建数组. 每添加一个元素就会分配一次内存空间.
    NSMutableArray *apps = [NSMutableArray arrayWithCapacity:appArray.count];
    
    // 遍历数组
    [appArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        // 创建模型
        FQDemoModel *app = [FQDemoModel appWithDict:dict];
        // 将模型添加到模型数组中
        [apps addObject:app];
    }];
    
    return apps.copy;
}
@end

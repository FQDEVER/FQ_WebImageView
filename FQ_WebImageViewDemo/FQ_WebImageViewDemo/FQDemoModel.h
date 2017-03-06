//
//  AppDelegate.h
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQDemoModel : NSObject
/**
 *  应用名称
 */
@property (nonatomic, copy) NSString *name;

/**
 *  应用图标
 */
@property (nonatomic, copy) NSString *icon;

/**
 *  下载数量
 */
@property (nonatomic, copy) NSString *download;
/**
 *  记录应用对应的图标图片
 */
//@property (nonatomic, strong) UIImage *image;

/**
 *  返回所有应用信息
 *
 */
+(NSArray *)apps;

+ (instancetype)appWithDict:(NSDictionary *)dict;
@end

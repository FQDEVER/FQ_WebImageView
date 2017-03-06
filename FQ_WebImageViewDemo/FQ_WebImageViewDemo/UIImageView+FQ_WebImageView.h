//
//  UIImageView+FQ_WebImageView.h
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (FQ_WebImageView)


- (void)fq_setImageWithURLString:(NSString *)URLString placeholder:(UIImage *)placeholder;

//终极方案
- (void)fq_setImageWithURLString:(NSString *)URLString placeholder:(UIImage *)placeholder finishBlock:(void (^)(UIImage *image)) finishedBlock;

@end

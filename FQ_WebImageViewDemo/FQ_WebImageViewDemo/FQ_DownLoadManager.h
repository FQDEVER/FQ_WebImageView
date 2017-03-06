//
//  FQ_DownLoadManager.h
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQ_DownLoadManager : NSObject

+ (instancetype)shareManager;


- (void)fq_downloadImageWithUrlString:(NSString *)urlString andImage:(UIImage *)placeholderImage finishBlock:(void (^)(UIImage *image)) finishedBlock;



- (void)fq_cancelDownloadImageWithURLString:(NSString *)URLString;

//取消展示.
-(void)fq_cancelImageShowCell:(NSString *)urlString;

@end

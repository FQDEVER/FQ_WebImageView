//
//  FQ_DownLoadImageOperation.h
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQ_DownLoadImageOperation : NSOperation

+ (instancetype)fq_downloadImageOperationWithUrlString:(NSString *)urlString finishBlock:(void (^)(UIImage *image)) finishedBlock;

@end

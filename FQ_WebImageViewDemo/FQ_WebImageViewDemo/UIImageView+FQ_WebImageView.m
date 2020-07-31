//
//  UIImageView+FQ_WebImageView.m
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "UIImageView+FQ_WebImageView.h"
#import "FQ_DownLoadManager.h"
#import <objc/runtime.h>

@interface UIImageView ()

@property(nonatomic,copy) NSString *currentURLString;

@end

@implementation UIImageView (FQ_WebImageView)

//终极方案
- (void)fq_setImageWithURLString:(NSString *)URLString placeholder:(UIImage *)placeholder finishBlock:(void (^)(UIImage *image)) finishedBlock {
    
    //用户滑动的时候.滑动的时候cell重用.所以可能当前待加载的图片与需要加载的图片不一致.那么就取消当前的.让最新加入的加入到队列中.
    if (self.currentURLString && ![URLString isEqualToString:self.currentURLString]) {
        
        [[FQ_DownLoadManager shareManager] fq_cancelImageShowCell:self.currentURLString];
        
    }
    
    self.currentURLString = URLString;
    
    self.image = placeholder;  //默认占位图
    
    __weak typeof(self) weakSelf = self;
    
    
    [[FQ_DownLoadManager shareManager] fq_downloadImageWithUrlString:self.currentURLString andImage:placeholder finishBlock:^(UIImage *image) {
        if (finishedBlock) {
            if ([image isEqual:placeholder]) {//两个图片相同的
                NSLog(@"有没有来这里的");
                finishedBlock(weakSelf.image);
            }else{
                finishedBlock(image);
            }
        }
        
    }];
    
}

- (void)fq_setImageWithURLString:(NSString *)URLString placeholder:(UIImage *)placeholder
{
    
    if (placeholder == nil) {
        placeholder = [UIImage new];
    }
    
    //用户滑动的时候
    if (self.currentURLString && ![URLString isEqualToString:self.currentURLString]) {
        
        [[FQ_DownLoadManager shareManager] fq_cancelImageShowCell:self.currentURLString];
        
    }
    
    self.currentURLString = URLString;
    
    self.image = placeholder;  //默认占位图
    
    __weak typeof(self) weakSelf = self;

    [[FQ_DownLoadManager shareManager] fq_downloadImageWithUrlString:self.currentURLString andImage:placeholder finishBlock:^(UIImage *image) {
        
            if (![image isEqual:placeholder]) {//防止cell重用.
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.image = image;
                });
                
            }
    }];

}



const char *FQURLString = "FQURLString";
- (void)setCurrentURLString:(NSString *)currentURLString {
    
    
    objc_setAssociatedObject(self, FQURLString, currentURLString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSString *)currentURLString {
    
    return  objc_getAssociatedObject(self, FQURLString);
    
}




@end

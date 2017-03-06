//
//  FQ_DownLoadImageOperation.m
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "FQ_DownLoadImageOperation.h"
#import "NSString+Path.h"
#import <ImageIO/ImageIO.h>

@interface FQ_DownLoadImageOperation ()

@property(nonatomic,copy) NSString *urlString;

@property(nonatomic,copy) void (^finishedBlock)(UIImage *image);


@end


@implementation FQ_DownLoadImageOperation

//给一个快速下载的类方法

+ (instancetype)fq_downloadImageOperationWithUrlString:(NSString *)urlString finishBlock:(void (^)(UIImage *image)) finishedBlock{
    
    
    FQ_DownLoadImageOperation *op = [[self alloc] init];
    
    op.urlString = urlString;
    
    op.finishedBlock = finishedBlock;
    
    
    return op;
    
}

//CPU调度该操作,会执行main
- (void)main {
    @autoreleasepool {
        
        //断言,保证必须传入完成回调,简化后续代码的分支
        NSAssert(self.finishedBlock != nil, @"必需传入回调的block");
        //在这里面执行下载操作
        NSLog(@"正在下载:%@",self.urlString);
        
        NSURL  *url = [NSURL URLWithString:self.urlString];
        
        //方案一:
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        UIImage *image = [UIImage imageWithData:data];
        
        //方案二:大图.使用方案二有惊喜
//        CGImageRef imgRef = [self createThumbnailCGImageFromURL:url andImageSize:600];//传入你需要图片的宽
//        UIImage *img = [UIImage imageWithCGImage:imgRef];
        
        
        NSString * path =self.urlString.appendCachePath;
        
        //将数据存入沙盒
        if (data != nil) {
            
            [data writeToFile:path atomically:YES];
        }
        
        //回主线程更新UI
        
        if (self.isCancelled) {
            
            NSLog(@"操作被取消了");
            
            return;
        }
        
        /*
         1.这里的思路.每次只让他来最多5条.然后其他的就让他等待.
         */
        
        if (image!=nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //如果有其他耗时操作来这里.例如VR渲染
                
                self.finishedBlock(image);
            });
        }
    }
    
}


//直接获取CGImageRef对象.不需要保存到本地.这样在内存中获取到我们需要的图片以后再保存.
-(CGImageRef )createThumbnailCGImageFromURL:(NSURL *)url andImageSize:(int)imageSize
{
    CGImageRef thumbnailImage;
    CGImageSourceRef imageSource;
    CFDictionaryRef imageOptions;
    CFStringRef imageKeys[3];
    CFTypeRef imageValues[3];
    CFNumberRef thumbnailSize;
    
    //先判断数据是否存在
    imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    if (imageSource == NULL) {
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    //创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    imageKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    imageValues[0] = (CFTypeRef)kCFBooleanTrue;
    
    imageKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    imageValues[1] = (CFTypeRef)kCFBooleanTrue;
    //缩放键值对
    imageKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    imageValues[2] = (CFTypeRef)thumbnailSize;
    
    imageOptions = CFDictionaryCreate(NULL, (const void **) imageKeys,
                                      (const void **) imageValues, 3,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    //获取缩略图
    thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, imageOptions);
    CFRelease(imageOptions);
    CFRelease(thumbnailSize);
    CFRelease(imageSource);
    if (thumbnailImage == NULL) {
        return NULL;
    }
    return thumbnailImage;
    
}



//将操作添加到可调度线程池中
-(void)start {
    
    [super start];
    
}


@end

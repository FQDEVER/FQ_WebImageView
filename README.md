# FQ_WebImageView

获取图片的方式.相信大家立马想到SDWebImage 和 YYWebImage.
但.....
当你的需求是拿到图片以后.还要做一些操作呢?例如拿到这张图片切个圆角再显示.例如将图片渲染成需要的样式再展示.图片小一点还好.也不占内存.处理还快.如果图片比较大.根本不需要下载下来.只是处理以后再展示而已.
那么....

思路很简单:

1.首先开启线程加载图片

2.每次加载图片需要分三步
2.1 内存是否存在
2.1.1 有就直接加载.
2.1.2 没有就走下一步

2.2沙盒是否有
2.2.1 沙盒有就加载
2.2.2没有就走下一步

2.3都没有就走下一步

3.查看是否正在下载.取消重复下载.

4.加入到队列中下载

5.下载成功.保存到内存和沙盒中.

代码如下:

    - (void)fq_downloadImageWithUrlString:(NSString *)urlString andImage:(UIImage *)placeholderImage finishBlock:(void (^)(UIImage *image)) finishedBlock
    {
    //添加到展示的里面.可能有线程安全问题
    @synchronized(mutableArray)
    {
        [self.showImageArr addObject:urlString];
    }
    //
    //判断内存和沙盒中是否有对应图片
    if ([self checkImageCache:urlString]) {
        
        //从内存中加载图片
        finishedBlock(self.imageCache[urlString]);
        return;
        
    }
    
    // 检查操作缓冲池
    if (self.operationCache[urlString] != nil) {
        return;
    }
    
    FQ_DownLoadImageOperation *downloadOp = [FQ_DownLoadImageOperation fq_downloadImageOperationWithUrlString:urlString finishBlock:^(UIImage *image) {
        
        
        //下载完成,移除操作
        [self.operationCache removeObjectForKey:urlString];
        
        BOOL isPossess = [self.showImageArr containsObject:urlString];
        
        if (isPossess) {
            //图片添加到缓存池.如果字典的个数已经达到了10个.那么就再删除.我们保证只有10张在内存中
            if (self.imageCache.count >= 10) {
                
                [self.imageCache removeObjectForKey:self.imageCache.allKeys[0]];
            }
            //将图片添加到图片缓存池
            [self.imageCache setObject:image forKey:urlString];
            
            NSLog(@"图片缓存池中已经有多少张图片%zd",self.imageCache.count);
        }
        
        finishedBlock(isPossess ? image : placeholderImage);
    
    }];
    [self.operationCache setObject:downloadOp forKey:urlString];
    
    [self.downloadQueue addOperation:downloadOp];
    
    }


期间肯定有cell重用的问题.我的解决方案是:

每次进来加载的时候判断和当前cell加载的URLString是否一致.一致则说明是哪个.不一致.说明是cell重用了.cell上一个URLString对应的操作我们只需要记录在一个数组中.该图片照片下载.或加载.但是不用展示即可.


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
                weakSelf.image = image;
            }
       }];
       }

 
核心:如果加载大图:那么使用获取CGImageRef对象的方式会快一些.如果需要使用大图做处理然后只是做显示使用.那么也建议使用这种方式.

//直接获取CGImageRef对象.不需要保存到本地.这样在内存中获取到我们需要的图片以后再保存.

这前辈12年写:http://supershll.blog.163.com/blog/static/37070436201298111139748/

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

最后献上demo:有兴趣的可以看看
https://github.com/fanqiguoguo/FQ_WebImageView

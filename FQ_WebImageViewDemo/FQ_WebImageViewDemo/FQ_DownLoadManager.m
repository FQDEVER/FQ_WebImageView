

#import "FQ_DownLoadManager.h"
#import "FQ_DownLoadImageOperation.h"
#import "NSString+Path.h"

@interface FQ_DownLoadManager ()


//操作缓存
@property (nonatomic,strong) NSMutableDictionary *operationCache;


//下载队列
@property (nonatomic,strong) NSOperationQueue *downloadQueue;


//图片缓存
@property (nonatomic,strong) NSMutableDictionary *imageCache;


//展示图片的数组
@property (nonatomic, strong) NSMutableArray *showImageArr;


@end

static NSString * mutableArray;

@implementation FQ_DownLoadManager

//单例
+ (instancetype)shareManager {
    
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}


//再写一个方法.取消显示.而不是取消下载
-(void)fq_cancelImageShowCell:(NSString *)urlString
{
    //从显示数组中移除
    @synchronized(mutableArray)
    {
        [self.showImageArr removeObject:urlString];
    }
}


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
    
    [downloadOp start];
}




//取消对应的下载操作
- (void)fq_cancelDownloadImageWithURLString:(NSString *)URLString {
    
    
    if (URLString.length == 0) return;
    
    //根据URL获得对应的下载操作
    FQ_DownLoadImageOperation *op = self.operationCache[URLString];
    
    if (op == nil) return;
    
    //取消下载
    [op cancel];
    
    [self.operationCache removeObjectForKey:URLString];
}

//检查内存中是否有对应的图片
- (BOOL)checkImageCache:(NSString *)URLString {
    
    if (self.imageCache[URLString] != nil) {
        
        NSLog(@"从内存中加载图片:%@",URLString);
        return YES;
    }
    
    //检查沙盒中是否有对应的图片
    UIImage *image = [UIImage imageWithContentsOfFile:URLString.appendCachePath];
    
    if (image != nil) {
        
        NSLog(@"从沙盒中加载图片:%@",URLString);
        //将图片加到图片缓存池中
        if (self.imageCache.count >= 10) {
            
            [self.imageCache removeObjectForKey:self.imageCache.allKeys[0]];
        }
        //
        [self.imageCache setObject:image forKey:URLString];
        
        NSLog(@"222222222222222图片缓存池中已经有多少张图片%zd",self.imageCache.count);
        
        return YES;
        
    }
    
    return  NO;
    
    
    
    
}

- (NSOperationQueue *)downloadQueue {
    
    if (_downloadQueue == nil) {
        
        _downloadQueue = [[NSOperationQueue alloc] init];
        
        _downloadQueue.maxConcurrentOperationCount = 5;
    }
    
    return  _downloadQueue;
    
}

- (NSMutableDictionary *)operationCache {
    
    if (_operationCache == nil) {
        
        _operationCache = [NSMutableDictionary dictionary];
        
    }
    
    return _operationCache;
    
}

- (NSMutableDictionary *)imageCache {
    
    if (_imageCache == nil) {
        
        _imageCache = [NSMutableDictionary dictionary];
        
    }
    
    return _imageCache;
    
}

-(NSMutableArray *)showImageArr
{
    if (!_showImageArr) {
        _showImageArr = [NSMutableArray array];
    }
    return _showImageArr;
}


@end

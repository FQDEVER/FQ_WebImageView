
#import "NSString+Path.h"


@implementation NSString (Path)

/**
 *  追加文档目录
 *
 *  @return 全路径
 */
- (NSString *)appendDocumentPath {
    // 获得document文件夹路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 获得文件全路径
    return [doc stringByAppendingPathComponent:[self lastPathComponent]];
}

/**
 *  追加缓存目录
 */
- (NSString *)appendCachePath {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // 获得文件全路径
    return [cacheDir stringByAppendingPathComponent:[self lastPathComponent]];
}
/**
 *  追加临时文件夹目录
 */
- (NSString *)appendTempPath {
    // NSTemporaryDirectory():获得沙盒目录中的临时文件夹的路径
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[self lastPathComponent]];
}
@end

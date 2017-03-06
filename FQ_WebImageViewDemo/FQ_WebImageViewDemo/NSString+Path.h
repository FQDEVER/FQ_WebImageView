

#import <Foundation/Foundation.h>

@interface NSString (Path)

/**
 *  追加文档目录
 *
 *  @return 全路径
 */
- (NSString *)appendDocumentPath;

/**
 *  追加缓存目录
 */
- (NSString *)appendCachePath;
/**
 *  追加临时文件夹目录
 */
- (NSString *)appendTempPath;
@end

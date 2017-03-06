//
//  AppDelegate.h
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+FQ_WebImageView.h"
@interface FQDemoCell : UITableViewCell
/**
 *  应用图标
 */
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
/**
 *  应用名称
 */
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

/**
 *  下载数量
 */
@property (nonatomic, weak) IBOutlet UILabel *downloadLabel;
@end

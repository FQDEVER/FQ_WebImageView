//
//  ViewController.m
//  FQ_WebImageViewDemo
//
//  Created by 范奇 on 17/3/6.
//  Copyright © 2017年 fanqi. All rights reserved.
//

#import "ViewController.h"
#import "FQDemoModel.h"
#import "FQDemoCell.h"
#import "NSString+Path.h"
#import "UIImageView+FQ_WebImageView.h"

@interface ViewController ()
/**
 *  应用信息
 */
@property (nonatomic, strong) NSArray *apps;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 该方法是iOS6.0出现,苹果是建议使用该方法获得cell
    FQDemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"apps" forIndexPath:indexPath];
    
    // 获得app
    FQDemoModel *app = self.apps[indexPath.row];
    // 设置 Cell...
    cell.nameLabel.text = app.name;
    cell.downloadLabel.text = app.download;
    
    // 使用FQ_WebImageView下载图片
    [cell.iconView fq_setImageWithURLString:app.icon placeholder:[UIImage imageNamed:@"user_default"]];
    
    return cell;
}

#pragma mark - 懒加载数据
- (NSArray *)apps {
    if (_apps == nil) {
        _apps = [FQDemoModel apps];
    }
    return _apps;
}
@end

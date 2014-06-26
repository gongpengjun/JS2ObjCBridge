//
//  GpjMasterViewController.m
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-26.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import "GpjMasterViewController.h"
#import "GpjDetailViewController.h"

@implementation GpjMasterViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"点击进入WebView";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    GpjDetailViewController * detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GpjDetailViewController"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    detailViewController.url = [NSURL fileURLWithPath:path];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end

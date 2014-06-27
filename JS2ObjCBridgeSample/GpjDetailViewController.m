//
//  GpjDetailViewController.m
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-26.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import "GpjDetailViewController.h"

@implementation GpjDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.opaque = NO;
}

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
    if ([functionName isEqualToString:@"setBackgroundColor"]) {
        [self setBackgroundColor:args callbackId:callbackId];
    } else {
        [super handleCall:functionName callbackId:callbackId args:args];
    }
}

#pragma mark - JavaScript Interface

- (void)setBackgroundColor:(NSArray*)args callbackId:(int)callbackId
{
    NSAssert2([args count] == 3, @"%s,%d wait exactly 3 arguments!",__FUNCTION__,__LINE__);
    NSNumber *red = (NSNumber*)[args objectAtIndex:0];
    NSNumber *green = (NSNumber*)[args objectAtIndex:1];
    NSNumber *blue = (NSNumber*)[args objectAtIndex:2];
    NSLog(@"setBackgroundColor(%@,%@,%@)",red,green,blue);
    self.webView.backgroundColor = [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1.0];
    [self returnResult:callbackId args:nil];
}

@end

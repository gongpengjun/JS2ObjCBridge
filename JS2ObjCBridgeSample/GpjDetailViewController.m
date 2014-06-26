//
//  GpjDetailViewController.m
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-26.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import "GpjDetailViewController.h"

@interface GpjDetailViewController () <UIAlertViewDelegate>
{
    int alertCallbackId;
}
@end

@implementation GpjDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.opaque = NO;
}

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
    if ([functionName isEqualToString:@"setBackgroundColor"]) {
        [self setBackgroundColor:args];
        [self returnResult:callbackId args:nil];
    } else if ([functionName isEqualToString:@"setPageTitle"]) {
        [self setPageTitle:args];
    } else if ([functionName isEqualToString:@"prompt"]) {
        alertCallbackId = callbackId;
        [self prompt:args];
    } else {
        NSLog(@"Unimplemented method '%@'",functionName);
    }
}

#pragma mark - JavaScript Interface

- (void)setBackgroundColor:(NSArray*)args
{
    if ([args count]!=3) {
        NSLog(@"setBackgroundColor wait exactly 3 arguments!");
        return;
    }
    NSNumber *red = (NSNumber*)[args objectAtIndex:0];
    NSNumber *green = (NSNumber*)[args objectAtIndex:1];
    NSNumber *blue = (NSNumber*)[args objectAtIndex:2];
    NSLog(@"setBackgroundColor(%@,%@,%@)",red,green,blue);
    self.webView.backgroundColor = [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1.0];
}

- (void)setPageTitle:(NSArray*)args
{
    if ([args count]!=1) {
        NSLog(@"setTitle wait exactly one argument!");
        return;
    }
    NSString *title = (NSString*)[args objectAtIndex:0];
    self.title = title;
}

- (void)prompt:(NSArray*)args
{
    if ([args count]!=1) {
        NSLog(@"prompt wait exactly one argument!");
        return;
    }
    
    NSString *message = (NSString*)[args objectAtIndex:0];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

// Just one example with AlertView that show how to return asynchronous results
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!alertCallbackId) return;
    
    NSLog(@"prompt result : %d",buttonIndex);
    
    BOOL result = buttonIndex==1?YES:NO;
    [self returnResult:alertCallbackId args:[NSNumber numberWithBool:result],nil];
    
    alertCallbackId = 0;
}


@end

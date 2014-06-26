//
//  GpjWebViewController.h
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-26.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GpjWebViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;
// handle JS call
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args;
// return result to JS
- (void)returnResult:(int)callbackId args:(id)arg, ...;
@end

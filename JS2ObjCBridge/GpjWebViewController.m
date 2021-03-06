//
//  GpjWebViewController.m
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-26.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import "GpjWebViewController.h"
#import "UIAlertView+Block.h"

@interface GpjWebViewController ()
@property (nonatomic, assign) BOOL goBackApp;
@property (nonatomic, assign) BOOL goBackRefresh;
@end

@implementation GpjWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    NSAssert(_webView.delegate == self, @"fatal error");
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    [_webView loadRequest:request];
}



#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	NSString *requestString = [[request URL] absoluteString];
    //NSLog(@"%s,%d request : %@",__FUNCTION__,__LINE__,requestString);
    if ([requestString hasPrefix:@"js-frame:"]) {
        [self handleJSFrameRequest:requestString];
        return NO;
    }
    
    return YES;
}

#pragma mark - JS2ObjcBridge

- (void)handleJSFrameRequest:(NSString *)requestString
{
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if(components.count == 4) {
        NSString *function = (NSString*)[components objectAtIndex:1];
        int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%s,%d function name: %@ args:%@ callbackId:%@",__FUNCTION__,__LINE__,function,argsAsString,@(callbackId));
        NSData * data = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *args = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self handleCall:function callbackId:callbackId args:args];
    }
}

// Call this function when you have results to send back to javascript callbacks
// callbackId : int comes from handleCall function
// args: list of objects to send to the javascript callback
- (void)returnResult:(int)callbackId args:(id)arg, ...;
{
    if (callbackId==0) return;
    
    va_list argsList;
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    if(arg != nil) {
        [resultArray addObject:arg];
        va_start(argsList, arg);
        while((arg = va_arg(argsList, id)) != nil)
        [resultArray addObject:arg];
        va_end(argsList);
    }
    
    NSString * jsText = nil;
    if(resultArray.count > 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:resultArray options:0 error:nil];
        NSString *resultArrayString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsText = [NSString stringWithFormat:@"JS2ObjCBridge.resultForCallback(%d,%@);",callbackId,resultArrayString];
    } else {
        jsText = [NSString stringWithFormat:@"JS2ObjCBridge.resultForCallback(%d);",callbackId];
    }
    // We need to perform selector with afterDelay 0 in order to avoid weird recursion stop
    // when calling JS2ObjCBridge in a recursion more then 200 times :s (fails ont 201th calls!!!)
    [self performSelector:@selector(returnResultAfterDelay:) withObject:jsText afterDelay:0];
}

-(void)returnResultAfterDelay:(NSString*)str
{
    // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}

// Implements all you native function in this one, by matching 'functionName' and parsing 'args'
// Use 'callbackId' with 'returnResult' selector when you get some results to send back to javascript
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
    NSLog(@"functionName:%@, callbackId:%@, args:%@",functionName,@(callbackId), args);
    if ([functionName isEqualToString:@"setTitle"]) {
        [self setPageTitle:args callbackId:callbackId];
    } else if ([functionName isEqualToString:@"goBackApp"]) {
        [self setGoBackApp:args callbackId:callbackId];
    } else if ([functionName isEqualToString:@"goBackRefresh"]) {
        [self setGoBackRefresh:args callbackId:callbackId];
    } else if ([functionName isEqualToString:@"log"]) {
        [self log:args callbackId:callbackId];
    } else if ([functionName isEqualToString:@"prompt"]) {
        [self showDialog:args callbackId:callbackId];
    } else {
        NSLog(@"Unimplemented method '%@'",functionName);
    }
}

#pragma mark - JavaScript API

- (void)setPageTitle:(NSArray*)args callbackId:(int)callbackId
{
    NSAssert2([args count] == 1, @"%s,%d wait exactly one argument!",__FUNCTION__,__LINE__);
    self.title = (NSString*)[args objectAtIndex:0];
    [self returnResult:callbackId args:nil];
}

- (void)setGoBackApp:(NSArray*)args callbackId:(int)callbackId
{
    NSAssert2([args count] == 1, @"%s,%d wait exactly one argument!",__FUNCTION__,__LINE__);
    _goBackApp = [(NSString*)[args objectAtIndex:0] boolValue];
    [self returnResult:callbackId args:nil];
}

- (void)setGoBackRefresh:(NSArray*)args callbackId:(int)callbackId
{
    NSAssert2([args count] == 1, @"%s,%d wait exactly one argument!",__FUNCTION__,__LINE__);
    _goBackRefresh = [(NSString*)[args objectAtIndex:0] boolValue];
    [self returnResult:callbackId args:nil];
}

- (void)log:(NSArray*)args callbackId:(int)callbackId
{
    NSAssert2([args count] == 1, @"%s,%d wait exactly one argument!",__FUNCTION__,__LINE__);
    NSString *message = (NSString*)[args objectAtIndex:0];
    NSLog(@"JS Log: %@",message);
}

- (void)showDialog:(NSArray*)args callbackId:(int)callbackId
{
    NSAssert2([args count] == 1, @"%s,%d wait exactly one argument!",__FUNCTION__,__LINE__);
    NSString *message = (NSString*)[args objectAtIndex:0];
    [UIAlertView showWithTitle:nil
                       message:message
             cancelButtonTitle:@"取消"
             otherButtonTitles:@[@"确定"]
                     onDismiss:^(NSInteger buttonIndex, NSInteger firstOtherButtonIndex) {
                         [self returnResult:callbackId args:@(YES),nil];
                     }
                      onCancel:^{
                          [self returnResult:callbackId args:@(NO),nil];
                      }];
}

#pragma mark - Actions

- (void)backButtonAction
{
    NSString *functionname = @"back_prompt(\"zh\")";
    NSString *backstr = [_webView stringByEvaluatingJavaScriptFromString:functionname];
    if ([backstr isKindOfClass:[NSString class]] && backstr.length > 0) {
        [UIAlertView showWithTitle:nil
                           message:backstr
                 cancelButtonTitle:@"不退出"
                 otherButtonTitles:@[@"退出"]
                         onDismiss:^(NSInteger buttonIndex, NSInteger firstOtherButtonIndex) {
                             if (buttonIndex == firstOtherButtonIndex) {
                                 if(self.webView.canGoBack) {
                                     [self.webView goBack];
                                 } else {
                                     [self doBack];
                                 }
                             }
                         }
                          onCancel:^{
                              // do nothing
                          }];
    } else {
        if(self.webView.canGoBack) {
            [self.webView goBack];
        } else {
            [self doBack];
        }
    }
}

- (void)doBack
{
    if(_goBackApp) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (_goBackRefresh) {
        [self.webView reload];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

//
//  UIAlertView+Block.m
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-27.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import "UIAlertView+Block.h"
#import <objc/runtime.h>

@implementation UIAlertView (Block) 

@dynamic dismissBlock;
@dynamic cancelBlock ;

#pragma mark - API

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtons
            onDismiss:(DismissBlock)dismissed
             onCancel:(CancelBlock)cancelled
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    alert.delegate = alert;
    alert.dismissBlock = dismissed;
    alert.cancelBlock = cancelled;
    
    for (NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (self.cancelBlock) self.cancelBlock();
    } else {
        if (self.dismissBlock) {
            NSInteger firstOtherButtonIndex = alertView.firstOtherButtonIndex;
            if(firstOtherButtonIndex < 0)
                firstOtherButtonIndex = alertView.cancelButtonIndex + 1;
            self.dismissBlock(buttonIndex, firstOtherButtonIndex);
        }
    }
}

#pragma mark - Accessor

- (void)setDismissBlock:(DismissBlock)dismissBlock
{
    objc_setAssociatedObject(self, "kDismissBlock", dismissBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DismissBlock)dismissBlock
{
    return objc_getAssociatedObject(self, "kDismissBlock");
}

- (void)setCancelBlock:(CancelBlock)cancelBlock
{
    objc_setAssociatedObject(self, "kCancelBlock", cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CancelBlock)cancelBlock
{
    return objc_getAssociatedObject(self, "kCancelBlock");
}

@end

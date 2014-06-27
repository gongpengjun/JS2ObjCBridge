//
//  UIAlertView+Block.h
//  JS2ObjCBridgeSample
//
//  Created by 巩 鹏军 on 14-6-27.
//  Copyright (c) 2014年 gongpengjun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DismissBlock)(NSInteger buttonIndex, NSInteger firstOtherButtonIndex);
typedef void (^CancelBlock)();

@interface UIAlertView (Block) <UIAlertViewDelegate>
@property (nonatomic, copy) DismissBlock dismissBlock;
@property (nonatomic, copy) CancelBlock cancelBlock ;
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtons
            onDismiss:(DismissBlock)dismissed
             onCancel:(CancelBlock)cancelled;
@end

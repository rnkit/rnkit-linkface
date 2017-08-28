//
//  STAlertView.h
//
//  Created by sluin on 15/12/24.
//  Copyright © 2015年 SunLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STAlertViewDelegate;

@interface STAlertView : UIView

- (STAlertView *)initWithTitle:(NSString *)title delegate:(id <STAlertViewDelegate> )delegate;

- (void)showOnView:(UIView *)view;

@end


@protocol STAlertViewDelegate <NSObject>

- (void)STAlertView:(STAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
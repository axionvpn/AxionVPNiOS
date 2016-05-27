//
//  UIViewController+AlertView.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/12/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AlertView)

-(void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

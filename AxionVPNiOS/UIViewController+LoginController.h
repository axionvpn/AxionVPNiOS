//
//  UIViewController+LoginController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 6/5/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXVLogInViewController.h"

@interface UIViewController (LoginController)  <AXVLogInViewControllerDelegate>

-(void)showLogInScreen;

@end

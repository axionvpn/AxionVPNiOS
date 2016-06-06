//
//  UIViewController+LoginController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 6/5/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "UIViewController+LoginController.h"

@implementation UIViewController (LoginController)

-(void)showLogInScreen
{
    AXVLogInViewController *logInViewController = [[AXVLogInViewController alloc] initWithDelegate:self];
    
    [self.tabBarController presentViewController:logInViewController
                                        animated:YES
                                      completion:nil];
}

#pragma mark - AXVLogInViewControllerDelegate

-(void)handleLogInViewControllerIsDone
{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}


@end

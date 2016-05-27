//
//  UIViewController+AlertView.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/12/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "UIViewController+AlertView.h"

@implementation UIViewController (AlertView)

-(void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end

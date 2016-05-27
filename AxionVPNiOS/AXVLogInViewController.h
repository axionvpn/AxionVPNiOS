//
//  AXVLogInViewController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/11/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AXVLogInViewController;

@protocol AXVLogInViewControllerDelegate <NSObject>

-(void)handleLogInViewControllerIsDone;

@end

@interface AXVLogInViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

-(instancetype)initWithDelegate:(id <AXVLogInViewControllerDelegate>)givenDelegate;

@end

//
//  AXVLogInViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/11/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVLogInViewController.h"
#import "AXVUserManager.h"
#import "AXVDataSource.h"
#import <SafariServices/SafariServices.h>
#import "AXVLoadingViewController.h"

@interface AXVLogInViewController () <UITextFieldDelegate>
{
    id <AXVLogInViewControllerDelegate> delegate;
    AXVLoadingViewController *loadingVC;
}
@end

@implementation AXVLogInViewController

-(instancetype)initWithDelegate:(id <AXVLogInViewControllerDelegate>)givenDelegate
{
    self = [super init];
    
    if (self != nil)
    {
        delegate = givenDelegate;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextFieldTextChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    
        loadingVC = [[AXVLoadingViewController alloc] init];
    }
    
    return self;
}

#pragma mark - IBAction

-(IBAction)handleUserPressedLogInButton:(id)sender
{
    NSString *userName = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = self.passwordTextField.text;
    
    AXVUser *user = [AXVUser userWithUserName:userName andPassword:password];
    
    AXVDataSource *dataSource = [[AXVDataSource alloc] init];
    
    [loadingVC addToView:self.view];
    
    [dataSource authenticateUser:user
             withCompletionBlock:^(NSError *error, kAXVDataSourceAuthenticationInformation userInformation)
     {
         [loadingVC remove];
         
         if (userInformation != kAXVDataSourceAuthenticationInformationLoginSuccess &&
             userInformation != kAXVDataSourceAuthenticationInformationCredentialsCorrectButNotOnVPN)
         {
             if (error == nil)
             {
                 NSString *errorMessage = nil;
                 
                 if (userInformation == kAXVDataSourceAuthenticationInformationBadCredentials)
                 {
                     errorMessage = @"Either the username or the password enter are incorrect. Please check your credentials and try again.";
                 }
                 else if (userInformation == kAXVDataSourceAuthenticationInformationAccountNotActivated)
                 {
                     errorMessage = @"Your account has not been activated yet. Please check your email and try again.";
                 }
                 else if (userInformation == kAXVDataSourceAuthenticationInformationError)
                 {
                     errorMessage = @"Something went wrong. Please try again.";
                 }
                 else
                 {
                     NSLog(@"%d",userInformation);
                 }
                 
                 error = [NSError errorWithDomain:@"com.axionvpn"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
             }
             
             [self showErrorAlertWithTitle:@"Error"
                                andMessage:[NSString stringWithFormat:@"An error occured when logging in: %@",error.localizedDescription]];
         }
         else
         {
             [[AXVUserManager sharedInstance] handleUserLoggedInAsUser:user];
            
             [delegate handleLogInViewControllerIsDone];
         }
     }];
}

- (IBAction)handleUserPressedGetAnAccountButton:(id)sender
{
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://axionvpn.com/vpn"]];
    
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [self.passwordTextField resignFirstResponder];
        [self handleUserPressedLogInButton:nil];
    }
    
    return YES;
}

#pragma mark - UITextFieldTextDidChangeNotification

-(void)handleTextFieldTextChanged:(NSNotification *)notification
{
    NSString *userName = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = self.passwordTextField.text;
    
    if (userName == nil ||
        [userName isEqualToString:@""] == YES ||
        password == nil ||
        [password isEqualToString:@""] == YES)
    {
        [self.logInButton setEnabled:NO];
        [self.logInButton setAlpha:.5];
    }
    else
    {
        [self.logInButton setEnabled:YES];
        [self.logInButton setAlpha:1.0];
    }
}

@end

//
//  AppDelegateViewHelper.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/11/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AppDelegateViewHelper.h"
#import "AXVServerListViewController.h"
#import "AXVLogInViewController.h"
#import "AXVUserManager.h"

@interface AppDelegateViewHelper ()
{
    UIWindow *window;
    AXVServerListViewController *viewController;
}
@end
@implementation AppDelegateViewHelper

-(void)setUpViewControllers
{
    [self setUpAppearances];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Set up server list
    {
        viewController = [[AXVServerListViewController alloc] init];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [navController.navigationBar setTranslucent:NO];
        
        [window setRootViewController:navController];
    }
    
    [window makeKeyAndVisible];
}

-(void)setUpAppearances
{
    UIColor *axionGreenColor = [UIColor colorWithRed:0.576
                                               green:0.745
                                                blue:0.298
                                               alpha:1.000];
    
    //UIBarButtonItem
    {
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    }
    
    //UINavigationBar
    {
        //Bar tint color
        [[UINavigationBar appearance] setBarTintColor:axionGreenColor];
        
        //Bar title text
        NSMutableDictionary *titleTextDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
        [titleTextDictionary setObject:[UIColor whiteColor]
                                forKey:NSForegroundColorAttributeName];
        [[UINavigationBar appearance] setTitleTextAttributes:titleTextDictionary];
    }
}

@end

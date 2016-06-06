//
//  AppDelegateViewHelper.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/11/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AppDelegateViewHelper.h"
#import "AXVServerListViewController.h"
#import "AXVGeositeMapViewController.h"
#import "AXVSettingsTableViewController.h"

@interface AppDelegateViewHelper ()
{
    UIWindow *window;
}
@end

@implementation AppDelegateViewHelper

-(void)setUpViewControllers
{
    [self setUpAppearances];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSArray <Class> *viewControllerClassesArray = @[[AXVServerListViewController class],
                                                    [AXVGeositeMapViewController class],
                                                    [AXVSettingsTableViewController class]];
    
    for (Class viewControllerclass in viewControllerClassesArray)
    {
        UIViewController *viewController = [[viewControllerclass alloc] init];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//        [navController.navigationBar setTranslucent:NO];

        [tabBarController addChildViewController:navController];
    }
    
    
    [window setRootViewController:tabBarController];
    [window makeKeyAndVisible];
}

-(void)setUpAppearances
{
    //UINavigationBar
    {
        //Bar tint color
        [[UINavigationBar appearance] setBarTintColor:AxionGreenColor];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

        //Bar title text
        NSMutableDictionary *titleTextDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
        [titleTextDictionary setObject:[UIColor whiteColor]
                                forKey:NSForegroundColorAttributeName];
        [[UINavigationBar appearance] setTitleTextAttributes:titleTextDictionary];
    }
    
    //UITabBar
    {
        [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setTintColor:AxionGreenColor];
    }
}

@end

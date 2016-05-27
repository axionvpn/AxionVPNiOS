//
//  AppDelegate.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/6/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegateViewHelper.h"

@interface AppDelegate ()
{
    AppDelegateViewHelper *viewHelper;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    viewHelper = [[AppDelegateViewHelper alloc] init];
    [viewHelper setUpViewControllers];
    
    return YES;
}

@end

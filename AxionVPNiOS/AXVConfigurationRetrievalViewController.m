//
//  AXVConfigurationRetrievalViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 9/20/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVConfigurationRetrievalViewController.h"
#import "AXVDataSource.h"
#import "AXVUserManager.h"

@interface AXVConfigurationRetrievalViewController ()
{
    AXVDataSource *dataSource;
}

@end

@implementation AXVConfigurationRetrievalViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    dataSource = [[AXVDataSource alloc] init];
    loadingVC = [[AXVLoadingViewController alloc] init];
}

-(void)retrieveConfigurationForGeosite:(AXVGeosite *)geoSite
{
    [loadingVC addToView:self.navigationController.view];
    [loadingVC setTopLabelText:@"Retrieving VPN profile.."];
    
    dataSource = [[AXVDataSource alloc] init];
    
    [dataSource getVPNConfigurationForUser:[[AXVUserManager sharedInstance] currentUser]
                                andGeosite:geoSite
                       withCompletionBlock:^(NSError *error, AXVVPNConfiguration *configuration)
     {
         [loadingVC remove];
         
         if (error != nil)
         {
             NSLog(@"Error getting vpn config: %@",error);
             [self showErrorAlertWithTitle:@"Error"
                                andMessage:[NSString stringWithFormat:@"Error connecting to VPN: %@",error.localizedDescription]];
         }
         else
         {
             [self showActivityViewForConfiguration:configuration];
         }
     }];
}

-(void)showActivityViewForConfiguration:(AXVVPNConfiguration *)configuration
{
    NSURL *url = [configuration writeConfigurationFileToDocumentsDirectory];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                                                                         applicationActivities:nil];
    
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
}

@end

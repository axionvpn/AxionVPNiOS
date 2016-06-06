//
//  AXVServerListViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/6/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVServerListViewController.h"
#import "AXVUserManager.h"
#import "AXVGeositeManager.h"
#import "AXVLogInViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import "AXVLoadingViewController.h"
#import "PacketTunnelProvider.h"
#import "AXVGeositeMapViewController.h"
#import "AXVGeositeTableViewCell.h"
#import "AXVSettingsTableViewController.h"

static NSString *const kAXVServerListViewControllerCellIdentifier = @"kAXVServerListViewControllerCellIdentifier";

@interface AXVServerListViewController () <UITableViewDelegate, UITableViewDataSource, AXVLogInViewControllerDelegate>
{
    NSArray <AXVGeosite *> *geositesArray;
    UIRefreshControl *refreshControl;
    AXVLogInViewController *logInViewController;
    AXVLoadingViewController *loadingVC;
    
    AXVGeositeMapViewController *mapVC;
}

@end

@implementation AXVServerListViewController

-(instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.title = @"List View";
        self.navigationItem.title = @"Choose a Location";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"List View"
                                                        image:[UIImage imageNamed:@"ic_location_city_36pt"]
                                                          tag:0];
        
        loadingVC = [[AXVLoadingViewController alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleGeositesLoaded:)
                                                     name:kAXVGeositeManagerLoadedGeositesNotificationName
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Refresh control
    {
        refreshControl = [[UIRefreshControl alloc] init];
        [self resetRefreshControlTitle];
        [refreshControl addTarget:self
                           action:@selector(handleUserDidPullToRefresh)
                 forControlEvents:UIControlEventValueChanged];
        
        [self.tableView addSubview:refreshControl];
    }
    
    //Table view cells
    {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AXVGeositeTableViewCell class]) bundle:nil]
             forCellReuseIdentifier:kAXVServerListViewControllerCellIdentifier];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[AXVUserManager sharedInstance] currentUser] != nil &&
        geositesArray == nil)
    {
        [self getGeoSites];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if ([[AXVUserManager sharedInstance] currentUser] == nil)
    {
        [self showLogInScreen];
    }
}

#pragma mark - Refresh control methods

-(void)handleUserDidPullToRefresh
{
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [refreshControl setAttributedTitle:title];
    
    [self getGeoSites];
}

-(void)resetRefreshControlTitle
{
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [refreshControl setAttributedTitle:title];
}

-(void)getGeoSites
{
    [loadingVC addToView:self.navigationController.view];

    [[AXVGeositeManager sharedInstance] loadGeosites];
}

#pragma mark - kAXVGeositeManagerLoadedGeositesNotificationName

-(void)handleGeositesLoaded:(NSNotification *)notification
{
    [loadingVC remove];
    
    //Refresh control
    {
        [refreshControl endRefreshing];
        
        [self performSelector:@selector(resetRefreshControlTitle)
                   withObject:nil
                   afterDelay:.5];
    }
    
    if ([notification.object isKindOfClass:[NSError class]] == YES)
    {
        NSError *error = notification.object;
        NSLog(@"Error getting geosites: %@",error);
        [self showErrorAlertWithTitle:@"Error"
                           andMessage:[NSString stringWithFormat:@"Error obtaining locations: %@",error.localizedDescription]];
        
    }
    else
    {
        geositesArray = notification.object;
        
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return geositesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AXVGeositeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAXVServerListViewControllerCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[AXVGeositeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:kAXVServerListViewControllerCellIdentifier];
    }
    
    AXVGeosite *geosite = [geositesArray objectAtIndex:indexPath.row];
    
    [cell handleGeosite:geosite];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AXVGeosite *geosite = [geositesArray objectAtIndex:indexPath.row];
    
//    [loadingVC addToView:self.navigationController.view];
    
//    [dataSource getVPNConfigurationForUser:[[AXVUserManager sharedInstance] currentUser]
//                                andGeosite:geosite
//                       withCompletionBlock:^(NSError *error, AXVVPNConfiguration *configuration)
//    {
//        [loadingVC remove];
//        
//        if (error != nil)
//        {
//            NSLog(@"Error getting vpn config: %@",error);
//            [self showErrorAlertWithTitle:@"Error"
//                               andMessage:[NSString stringWithFormat:@"Error connecting to VPN: %@",error.localizedDescription]];
//        }
//        else
//        {
//            NETunnelProviderManager *vpnManager = [[NETunnelProviderManager alloc] init];
//            
//            [vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error)
//            {
//                if (error == nil)
//                {
//                    if (vpnManager.protocolConfiguration == nil)
//                    {
//                        //Protocol
//                        {
//                            NETunnelProviderProtocol *protocol = [[NETunnelProviderProtocol alloc] init];
//                            [protocol setServerAddress:configuration.vpnServer];
//                            
//                            //proxy settings
//                            {
//                                NEProxySettings *proxySettings = [[NEProxySettings alloc] init];
//                                
//                                //Proxy server
//                                {
//                                    NEProxyServer *proxyServer = [[NEProxyServer alloc] initWithAddress:configuration.vpnServer
//                                                                                                   port:configuration.port.integerValue];
//                                    
//                                    [proxySettings setHTTPServer:proxyServer];
//                                }
//                                
//                                [protocol setProxySettings:proxySettings];
//                            }
//                            
//                            [vpnManager setProtocolConfiguration:protocol];
//                        }
//
//                        [vpnManager setEnabled:YES];
//                        
//                        [vpnManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error)
//                         {
//                             if (error != nil)
//                             {
//                                 NSLog(@"Error saving to preferences: %@",error);
//                             }
//                             else
//                             {
//                                 NSLog(@"Saved to preferences successfully!!!");
//                             }
//                         }];
//                    }
//                    else
//                    {
//                        NSLog(@"VPN manager protocol config already set!");
//                    }
//                }
//                else
//                {
//                    NSLog(@"Error loading from preferences: %@",error);
//                }
//            }];
//        }
//    }];
}

@end

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
#import "AXVDataSource.h"

static NSString *const kAXVServerListViewControllerCellIdentifier = @"kAXVServerListViewControllerCellIdentifier";

@interface AXVServerListViewController () <UITableViewDelegate, UITableViewDataSource, AXVLogInViewControllerDelegate>
{
    NSArray <AXVGeosite *> *geositesArray;
    UIRefreshControl *refreshControl;
    AXVLogInViewController *logInViewController;
    AXVLoadingViewController *loadingVC;
    
    AXVGeositeMapViewController *mapVC;
    
    AXVDataSource *dataSource;
    
    NETunnelProviderManager *tunnelManager;
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
    
    [loadingVC addToView:self.navigationController.view];
    
    dataSource = [[AXVDataSource alloc] init];
    
    [dataSource getVPNConfigurationForUser:[[AXVUserManager sharedInstance] currentUser]
                                andGeosite:geosite
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
            [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
                
                if (error != nil)
                {
                    NSLog(@"error = %@",error);
                }
                else
                {
                    tunnelManager = managers.firstObject;
                    
                    if (tunnelManager == nil)
                    {
                        tunnelManager = [[NETunnelProviderManager alloc] init];
                        tunnelManager.localizedDescription = geosite.geoArea;
                        
                        //Provider protocol
                        {
                            NETunnelProviderProtocol *providerProtocol = [[NETunnelProviderProtocol alloc] init];
                            providerProtocol.serverAddress = configuration.vpnServer;
                            providerProtocol.providerConfiguration = @{@"something":@"something"};
                            providerProtocol.providerBundleIdentifier = @"com.axionvpn.AxionVPNiOS.PT";
                            
                            tunnelManager.protocolConfiguration = providerProtocol;
                        }
                        
                        [tunnelManager setEnabled:YES];
                        
                        [tunnelManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error)
                        {
                            if (error != nil)
                            {
                                NSLog(@"Error saving to prefs: %@",error);
                            }
                            else
                            {
                                NETunnelProviderSession *session = (NETunnelProviderSession *)tunnelManager.connection;
                                
                                NSError *providerError = nil;
                                
                                [session sendProviderMessage:[@"Hello provider" dataUsingEncoding:NSUTF8StringEncoding]
                                                 returnError:&providerError
                                             responseHandler:^(NSData * _Nullable responseData)
                                 {
                                     NSLog(@"Response: %@",[[NSString alloc] initWithData:responseData
                                                                                 encoding:NSUTF8StringEncoding]);
                                 }];
                                
                                if (providerError != nil)
                                {
                                    switch (providerError.code)
                                    {
                                        case NEVPNErrorConfigurationInvalid:
                                            NSLog(@"VPN config invalid");
                                            break;
                                        case NEVPNErrorConfigurationDisabled:
                                            NSLog(@"VPN config disabled");
                                            break;
                                        case NEVPNErrorConnectionFailed:
                                            NSLog(@"VPN connection failed");
                                            break;
                                        case NEVPNErrorConfigurationStale:
                                            NSLog(@"VPN config stale");
                                            break;
                                        case NEVPNErrorConfigurationReadWriteFailed:
                                            NSLog(@"VPN config read/write failed");
                                            break;
                                        case NEVPNErrorConfigurationUnknown:
                                            NSLog(@"VPN config unknown");
                                            break;
                                            
                                        default:
                                            NSLog(@"Default???");
                                            break;
                                    }
                                    
                                    NSLog(@"%@",providerError);
                                }
   
                            }
                        }];
                    }
                }
            }];
        }
    }];
}

@end

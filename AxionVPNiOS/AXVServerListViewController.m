//
//  AXVServerListViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/6/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVServerListViewController.h"
#import "AXVUserManager.h"
#import "AXVDataSource.h"
#import "AXVLogInViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import "AXVLoadingViewController.h"
#import "PacketTunnelProvider.h"

static NSString *const kAXVServerListViewControllerCellIdentifier = @"kAXVServerListViewControllerCellIdentifier";

@interface AXVServerListViewController () <UITableViewDelegate, UITableViewDataSource, AXVLogInViewControllerDelegate>
{
    AXVDataSource *dataSource;
    NSArray <AXVGeosite *> *geositesArray;
    UIRefreshControl *refreshControl;
    AXVLogInViewController *logInViewController;
    AXVLoadingViewController *loadingVC;
}
@end

@implementation AXVServerListViewController

-(instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        dataSource = [[AXVDataSource alloc] init];
        self.title = @"Choose a Location";
        loadingVC = [[AXVLoadingViewController alloc] init];
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
    
    //log out button
    {
        UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(logOut)];
        [self.navigationItem setLeftBarButtonItem:logOutButton];
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

-(void)showLogInScreen
{
    logInViewController = [[AXVLogInViewController alloc] initWithDelegate:self];
    
    [self.navigationController presentViewController:logInViewController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - logout

-(void)logOut
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Log Out?"
                                                                             message:@"Are you sure you want to log out?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
 
    UIAlertAction *logOutAction = [UIAlertAction actionWithTitle:@"Log Out"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       [[AXVUserManager sharedInstance] logOut];
                                       [self showLogInScreen];
                                   }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alertController addAction:logOutAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
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

    [dataSource getGeositesWithCompletionBlock:^(NSError *error, NSArray <AXVGeosite *> *givenGeositesArray)
     {
         [loadingVC remove];
         
         //Refresh control
         {
             [refreshControl endRefreshing];
             
             [self performSelector:@selector(resetRefreshControlTitle)
                        withObject:nil
                        afterDelay:.5];
         }
         
         if (error != nil)
         {
             NSLog(@"Error getting geosites: %@",error);
             [self showErrorAlertWithTitle:@"Error"
                                andMessage:[NSString stringWithFormat:@"Error obtaining locations: %@",error.localizedDescription]];

         }
         else
         {
             geositesArray = givenGeositesArray;
             [self.tableView reloadData];
         }
     }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return geositesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAXVServerListViewControllerCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kAXVServerListViewControllerCellIdentifier];
    }
    
    AXVGeosite *geosite = [geositesArray objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:geosite.geoArea];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AXVGeosite *geosite = [geositesArray objectAtIndex:indexPath.row];
    
    [loadingVC addToView:self.navigationController.view];
    
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
            NETunnelProviderManager *vpnManager = [[NETunnelProviderManager alloc] init];
            
            [vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error)
            {
                if (error == nil)
                {
                    if (vpnManager.protocolConfiguration == nil)
                    {
                        //Protocol
                        {
                            NETunnelProviderProtocol *protocol = [[NETunnelProviderProtocol alloc] init];
                            [protocol setServerAddress:configuration.vpnServer];
                            
                            //proxy settings
                            {
                                NEProxySettings *proxySettings = [[NEProxySettings alloc] init];
                                
                                //Proxy server
                                {
                                    NEProxyServer *proxyServer = [[NEProxyServer alloc] initWithAddress:configuration.vpnServer
                                                                                                   port:configuration.port.integerValue];
                                    
                                    [proxySettings setHTTPServer:proxyServer];
                                }
                                
                                [protocol setProxySettings:proxySettings];
                            }
                            
                            [vpnManager setProtocolConfiguration:protocol];
                        }

                        [vpnManager setEnabled:YES];
                        
                        [vpnManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error)
                         {
                             if (error != nil)
                             {
                                 NSLog(@"Error saving to preferences: %@",error);
                             }
                             else
                             {
                                 NSLog(@"Saved to preferences successfully!!!");
                             }
                         }];
                    }
                    else
                    {
                        NSLog(@"VPN manager protocol config already set!");
                    }
                }
                else
                {
                    NSLog(@"Error loading from preferences: %@",error);
                }
            }];
        }
    }];
}

#pragma mark - AXVLogInViewControllerDelegate

-(void)handleLogInViewControllerIsDone
{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

@end

//
//  AXVSettingsTableViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 6/3/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVSettingsTableViewController.h"
#import "AXVTableSectionRepresentation.h"
#import "AXVUserManager.h"
#import "AXVIPHelper.h"

@interface AXVSettingsTableViewController ()
{
    NSMutableArray  <AXVTableSectionRepresentation *> *tableSectionRepsArray;
}
@end

@implementation AXVSettingsTableViewController

-(instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.title = @"Settings";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                        image:[UIImage imageNamed:@"ic_settings_36pt"]
                                                          tag:0];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableSectionRepsArray = [[NSMutableArray alloc] init];
    
    {
        AXVTableSectionRepresentation *rep = [[AXVTableSectionRepresentation alloc] init];
        [rep setCellsArray:@[self.logOutCell]];

        [tableSectionRepsArray addObject:rep];
    }
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Username label
    {
        AXVUser *user =  [[AXVUserManager sharedInstance] currentUser];
        
        NSString *string = [NSString stringWithFormat:@"You are currently logged in as "];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]}];

        NSAttributedString *userNameString = [[NSAttributedString alloc] initWithString:user.userName
                                                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:13.0]}];
        [attributedString appendAttributedString:userNameString];
        [self.userNameLabel setAttributedText:attributedString];
    }
    
    //IP Address label
    {
        NSString *string = [NSString stringWithFormat:@"Your current IP Address is \n"];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]}];
        
        NSAttributedString *ipAddressString = [[NSAttributedString alloc] initWithString:[AXVIPHelper getIPAddress]
                                                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:13.0]}];
        [attributedString appendAttributedString:ipAddressString];
        [self.ipAddressLabel setAttributedText:attributedString];
    }
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableSectionRepsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AXVTableSectionRepresentation *rep = [tableSectionRepsArray objectAtIndex:section];
    return rep.cellsArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    AXVTableSectionRepresentation *rep = [tableSectionRepsArray objectAtIndex:section];

    return rep.sectionTitle;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AXVTableSectionRepresentation *rep = [tableSectionRepsArray objectAtIndex:indexPath.section];
    
    return [rep.cellsArray objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.logOutCell)
    {
        [self logOut];
    }
}

#pragma mark - AXVLoginViewControllerDelegate

-(void)handleLogInViewControllerIsDone
{
    [self.tabBarController setSelectedIndex:0];
    [super handleLogInViewControllerIsDone];
}

@end

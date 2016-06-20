//
//  AXVSettingsTableViewController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 6/3/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXVSettingsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableViewCell *logOutCell;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipAddressLabel;

@end

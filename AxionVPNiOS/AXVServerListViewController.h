//
//  AXVServerListViewController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/6/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXVConfigurationRetrievalViewController.h"

@interface AXVServerListViewController : AXVConfigurationRetrievalViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

//
//  AXVGeositeTableViewCell.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/26/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXVGeosite.h"
@interface AXVGeositeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *geositeNameLabel;

-(void)handleGeosite:(AXVGeosite *)geosite;

@end

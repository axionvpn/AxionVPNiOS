//
//  AXVGeositeTableViewCell.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/26/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVGeositeTableViewCell.h"

@implementation AXVGeositeTableViewCell

-(void)handleGeosite:(AXVGeosite *)geosite
{
    UIImage *image = [UIImage imageNamed:geosite.imagePath];
    [self.backgroundImageView setImage:image];
    
    [self.geositeNameLabel setText:geosite.geoArea];
}

@end

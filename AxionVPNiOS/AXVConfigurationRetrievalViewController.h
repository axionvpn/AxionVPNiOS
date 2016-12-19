//
//  AXVConfigurationRetrievalViewController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 9/20/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXVGeosite.h"
#import "AXVLoadingViewController.h"

@interface AXVConfigurationRetrievalViewController : UIViewController
{
    AXVLoadingViewController *loadingVC;
}

-(void)retrieveConfigurationForGeosite:(AXVGeosite *)geoSite;

@end

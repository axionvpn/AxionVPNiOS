//
//  AXVGeositeMapViewController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/25/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXVGeosite.h"
#import <MapKit/MapKit.h>
#import "AXVConfigurationRetrievalViewController.h"

@interface AXVGeositeMapViewController : AXVConfigurationRetrievalViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

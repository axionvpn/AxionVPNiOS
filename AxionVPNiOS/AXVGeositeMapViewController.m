//
//  AXVGeositeMapViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/25/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVGeositeMapViewController.h"
#import "AXVGeositeManager.h"
#import <QuartzCore/QuartzCore.h>
#import "AXVDataSource.h"
#import "AXVUserManager.h"

@interface AXVGeositeAnnotation : NSObject <MKAnnotation>

@property (nonatomic, weak) AXVGeosite *geoSite;

-(instancetype)initWithAXVGeosite:(AXVGeosite *)geosite;

@end

@implementation AXVGeositeAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(instancetype)initWithAXVGeosite:(AXVGeosite *)geosite
{
    self = [super init];
    
    if (self != nil)
    {
        self.geoSite = geosite;
        coordinate = geosite.coordinateLocation;
        title = geosite.geoArea;
    }
    
    return self;
}

@end

static NSString *const kAXVGeositeMapViewControllerPinReuseIdentifier = @"kAXVGeositeMapViewControllerPinReuseIdentifier";

@interface AXVGeositeMapViewController () <MKMapViewDelegate>
{
    NSArray <AXVGeosite *> *geositesArray;
    AXVDataSource *dataSource;
}
@end

@implementation AXVGeositeMapViewController

-(instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.title = @"Map View";
        self.navigationItem.title = @"All Locations";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Map View"
                                                        image:[UIImage imageNamed:@"ic_location_on_36pt"]
                                                          tag:0];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadedGeosites:)
                                                     name:kAXVGeositeManagerLoadedGeositesNotificationName
                                                   object:nil];
        
        dataSource = [[AXVDataSource alloc] init];
    }
    
    return self;
}

-(void)loadedGeosites:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSError class]] == NO)
    {
        geositesArray = notification.object;
        [self loadPointsOnMap];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadPointsOnMap];
}

-(void)loadPointsOnMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (AXVGeosite *geosite in geositesArray)
    {
        AXVGeositeAnnotation *annotation = [[AXVGeositeAnnotation alloc] initWithAXVGeosite:geosite];
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:kAXVGeositeMapViewControllerPinReuseIdentifier];
    
    [pinAnnotationView setCanShowCallout:YES];
    
    //Set up connect button
    {
        CGRect frame = CGRectMake(0,
                                  0,
                                  100,
                                  pinAnnotationView.frame.size.height);
        UIButton *button =  [[UIButton alloc] initWithFrame:frame];
        [button setTitle:@"Choose"
                forState:UIControlStateNormal];
        [button setBackgroundColor:AxionGreenColor];
        button.layer.cornerRadius = 10;
        button.clipsToBounds = YES;
        
        pinAnnotationView.rightCalloutAccessoryView = button;
    }
    
    return pinAnnotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    AXVGeositeAnnotation *annotation = view.annotation;
    
    [self retrieveConfigurationForGeosite:annotation.geoSite];
}

@end

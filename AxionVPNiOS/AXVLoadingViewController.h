//
//  AXVLoadingViewController.h
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/17/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXVLoadingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *smallBlackSquareView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

-(void)addToView:(UIView *)superView;
-(void)remove;

@end

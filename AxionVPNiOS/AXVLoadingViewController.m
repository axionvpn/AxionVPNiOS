//
//  AXVLoadingViewController.m
//  AxionVPNiOS
//
//  Created by AxionVPN on 5/17/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "AXVLoadingViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AXVLoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Small black square view
    {
        self.smallBlackSquareView.layer.cornerRadius = 5;
        self.smallBlackSquareView.layer.masksToBounds = YES;
    }
    
    //Indicator
    {
        [self.activityIndicatorView startAnimating];
    }
}

-(void)addToView:(UIView *)superView
{
    while (superView.superview != nil)
    {
        superView = superView.superview;
    }
    
    [self.view setFrame:CGRectMake(0,
                                   0,
                                   superView.frame.size.width,
                                   superView.frame.size.height)];
    
    [superView addSubview:self.view];
}

-(void)remove
{
    [self.view removeFromSuperview];
}

-(void)setTopLabelText:(NSString *)topLabelText
{
    self.topLabel.text = topLabelText;
}

@end

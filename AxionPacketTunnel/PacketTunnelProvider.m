//
//  PacketTunnelProvider.m
//  AxionPacketTunnel
//
//  Created by AxionVPN on 5/15/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import <UIKit/UIKit.h>

@interface PacketTunnelProvider ()
{
    NWUDPSession *session;
    void (^startCompletionHandler)(NSError * __nullable error);
}

@end

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler
{
    startCompletionHandler = completionHandler;
    
    NWEndpoint *endPoint = [NWHostEndpoint endpointWithHostname:[options objectForKey:kPacketTunnelProviderServerAddressKey]
                                                           port:[options objectForKey:kPacketTunnelProviderPortKey]];
    
    session = [self createUDPSessionToEndpoint:endPoint
                                  fromEndpoint:nil];
    
    [session addObserver:self
              forKeyPath:@"state"
                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                 context:nil];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
	// Add code here to start the process of stopping the tunnel.
	completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
	// Add code here to handle the message.
    
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
	// Add code here to get ready to sleep.
	completionHandler();
}

- (void)wake
{
	// Add code here to wake up.
}

@end

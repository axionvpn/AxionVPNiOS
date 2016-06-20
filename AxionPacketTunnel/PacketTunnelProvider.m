//
//  PacketTunnelProvider.m
//  AxionPacketTunnel
//
//  Created by AxionVPN on 5/15/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

#import "PacketTunnelProvider.h"

#ifdef  AXION_VPN_IOS
#import "AxionVPNiOS-Swift.h"
#endif

#ifdef AXION_PACKET_TUNNEL
#import "AxionPacketTunnel-Swift.h"
#endif

@interface PacketTunnelProvider () <TunnelDelegate, ClientTunnelConnectionDelegate>
{
    ClientTunnel *tunnel;
    ClientTunnelConnection *tunnelConnection;
    void (^pendingStartCompletion)(NSError * __nullable error);
    void (^pendingStopCompletion)();
}

@end

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler
{
    NSLog(@"Hello world from the tunnel provider!");
    
    ClientTunnel *aTunnel = [[ClientTunnel alloc] init];
    aTunnel.delegate = self;
    
    NSError *error = [aTunnel startTunnel:self];
    
    if (error != nil)
    {
        completionHandler(error);
    }
    else
    {
        pendingStartCompletion = completionHandler;
        tunnel = aTunnel;
    }
}

-(void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"stop tunnel with reason");
    pendingStartCompletion = nil;
    
    pendingStopCompletion = completionHandler;
    [tunnel closeTunnel];
}

-(void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData * _Nullable))completionHandler
{
    NSLog(@"handle app message");
    
    NSString *messageString = [[NSString alloc] initWithData:messageData
                                                    encoding:NSUTF8StringEncoding];
    
    if (messageString == nil)
    {
        completionHandler(nil);
        return;
    }
    
    NSLog(@"Got a message from the app: %@",messageString);
    
    NSData *responseData = [@"Hello app" dataUsingEncoding:NSUTF8StringEncoding];
    completionHandler(responseData);
}

-(NEPacketTunnelNetworkSettings *)createTunnelSettingsFromConfiguration:(NSDictionary *)configuration
{
    NSLog(@"createTunnelSettingsFromConfiguration: Configuration dictionary: %@",configuration);
    
    NSString *tunnelAddress = tunnel.remoteHost;
    NSString *address = nil;
    NSString *netmask = nil;
    
    if (tunnelAddress != nil)
    {
        
    }
    else
    {
        return nil;
    }
    
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]initWithTunnelRemoteAddress:tunnelAddress];
    
    BOOL fullTunnel = YES;
    
    settings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[address]
                                                            subnetMasks:@[netmask]];
    
    
    
    
    
    settings.tunnelOverheadBytes = [NSNumber numberWithInteger:150];
    
    return settings;
}

#pragma mark - TunnelDelegate

-(void)tunnelDidOpen:(Tunnel *)targetTunnel
{
    NSLog(@"tunnel did open");
    tunnelConnection = [[ClientTunnelConnection alloc] initWithTunnel:tunnel
                                                     clientPacketFlow:self.packetFlow
                                                   connectionDelegate:self];
    [tunnelConnection open];
}

-(void)tunnelDidClose:(Tunnel *)targetTunnel
{
    NSLog(@"tunnel did close");
    if (pendingStartCompletion != nil)
    {
        pendingStartCompletion(tunnel.lastError);
        pendingStartCompletion = nil;
    }
    else if (pendingStopCompletion != nil)
    {
        pendingStopCompletion();
        pendingStopCompletion = nil;
    }
    else
    {
        [self cancelTunnelWithError:tunnel.lastError];
    }
    
    tunnel = nil;
}

-(void)tunnelDidSendConfiguration:(Tunnel *)targetTunnel configuration:(NSDictionary<NSString *,id> *)configuration
{
    NSLog(@"tunnel did send config");
}

#pragma mark - ClientTunnelConnectionDelegate

-(void)tunnelConnectionDidOpen:(ClientTunnelConnection *)connection configuration:(NSDictionary *)configuration
{
    NSLog(@"tunnel connection did open");
    NEPacketTunnelNetworkSettings *settings = [self createTunnelSettingsFromConfiguration:configuration];
    
    if (settings == nil)
    {
        NSError *error = [NSError errorWithDomain:@"com.axionvpn"
                                             code:SimpleTunnelErrorInternalError
                                         userInfo:nil];
        pendingStartCompletion(error);
        pendingStartCompletion = nil;
        return;
    }
    
    __block ClientTunnelConnection *blockTunnelConnection = tunnelConnection;
    __block void (^blockPendingStopCompletion)() = pendingStartCompletion;
    
    [self setTunnelNetworkSettings:settings
                 completionHandler:^(NSError * _Nullable error)
    {
        NSError *startError = nil;
        
        if (error != nil)
        {
            NSLog(@"Failed to set the tunnel network settings: %@",error);
            startError = [NSError errorWithDomain:@"com.axionvpn"
                                                 code:SimpleTunnelErrorBadConfiguration
                                             userInfo:nil];
        }
        else
        {
            [blockTunnelConnection startHandlingPackets];
        }
        
        blockPendingStopCompletion(startError);
        pendingStartCompletion = nil;
    }];
}

-(void)tunnelConnectionDidClose:(ClientTunnelConnection *)connection error:(NSError *)error
{
    NSLog(@"tunnel connection did close");
    tunnelConnection = nil;
    [tunnel closeTunnelWithError:error];
}

@end

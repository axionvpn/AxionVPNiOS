//
//  PacketTunnelProvider.h
//  AxionPacketTunnel
//
//  Created by AxionVPN on 5/15/16.
//  Copyright © 2016 AxionVPN. All rights reserved.
//

@import NetworkExtension;

static NSString *const kPacketTunnelProviderServerAddressKey = @"kPacketTunnelProviderServerAddressKey";
static NSString *const kPacketTunnelProviderPortKey = @"kPacketTunnelProviderPortKey";

@interface PacketTunnelProvider : NEPacketTunnelProvider

@end

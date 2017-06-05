//
//  udpSocket.m
//  LightsController
//
//  Created by JaredLee on 5/31/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import "UdpSocket.h"
#import "AdjustViewController.h"
#import "DevicesViewController.h"
#define UdpSocketHost @"255.255.255.255"
#define UdpSocketLocalPort 5001
#define UdpSocketRemotePort 5000
@interface UdpSocket()
@end
@implementation UdpSocket
+(instancetype)sharedSocketManager
{
    static UdpSocket *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
    
}

-(instancetype)init
{
    self = [super init];
    if(self){
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_udpSocket setIPv6Enabled:NO];
        [_udpSocket setIPv4Enabled:YES];
        NSError *error = nil;
        [_udpSocket enableBroadcast:YES error:&error];
        if (![_udpSocket enableBroadcast:YES error:&error])
        {
            NSLog(@"Error enableBroadcast: %@", error);
        }
        if (![_udpSocket bindToPort:UdpSocketLocalPort error:&error])
        {
            NSLog(@"Error binding: %@", error);
        }
        if (![_udpSocket beginReceiving:&error])
        {
            NSLog(@"Error receiving: %@", error);
        }        
        _devices = [NSMutableDictionary dictionary];
        _devicesArray = [[NSMutableArray alloc] init];
        _devicesNameData = [NSUserDefaults standardUserDefaults];
    }
    return self;
}
- (void)setAdjustViewController:(AdjustViewController *)viewController
{
    _adjustViewController = viewController;
}
- (void)setDevicesViewController:(DevicesViewController *)viewController
{
    _devicesViewController = viewController;
}
- (void)sendData:(Byte *)data
{
    NSData *b = [[NSData alloc] initWithBytes:data length:12];
    [_udpSocket sendData:b toHost:@"255.255.255.255" port:UdpSocketRemotePort withTimeout:-1 tag:0];
}
- (NSMutableDictionary *)getDevices
{
    return _devices;

}
- (Device *)getDevice:(UInt32)uid
{
    return [_devices objectForKey:@(uid)];
}
- (void)addDevice:(Device *)device uid:(UInt32)uid
{
    [_devices setObject:device forKey:@(uid)];
    [_devicesArray addObject:device];
}
- (void)setName:(UInt32)uid name:(NSString*)name
{
    [_devicesNameData setObject:name forKey:[NSString stringWithFormat:@"id_%d", uid]];
    [_devicesNameData synchronize];
}
- (NSString *)getName:(UInt32)uid
{
    return [_devicesNameData objectForKey:[NSString stringWithFormat:@"id_%d", uid]];
}
- (NSMutableArray*)getDevicesArray
{
    return _devicesArray;
}
- (Device *)getSelectedDevice
{
    return _devicesArray[selected];
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"send");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"Error receiving: %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    Byte *bytes = (Byte *)[data bytes];
    Byte CRC[] = {
        (Byte) (bytes[0] & bytes[2] & bytes[4] & bytes[6] & bytes[8]),
        (Byte) (bytes[1] | bytes[3] | bytes[5] | bytes[7] | bytes[9])
    };
    if (CRC[0] == bytes[10] && CRC[1] == bytes[11])
        [_devicesViewController udpData:bytes];

}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"address binded");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
     NSLog(@"Error%@", error);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
     NSLog(@"Error%@", error);
}

@end

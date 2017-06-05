//
//  udpSocket.h
//  LightsController
//
//  Created by JaredLee on 5/31/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "AdjustViewController.h"
#import "DevicesViewController.h"
#import "Device.h"
@interface UdpSocket : NSObject<GCDAsyncUdpSocketDelegate>
{
@public
    int selected;
}
@property(nonatomic,strong) GCDAsyncUdpSocket *udpSocket;
@property(nonatomic,strong) AdjustViewController *adjustViewController;
@property(nonatomic,strong) DevicesViewController *devicesViewController;
@property(nonatomic,strong) NSMutableDictionary *devices;
@property(nonatomic,strong) NSUserDefaults *devicesNameData;
@property(nonatomic,strong) NSMutableArray *devicesArray;
+ (instancetype)sharedSocketManager;
- (void)sendData:(Byte *)data;
- (NSMutableDictionary *)getDevices;
- (Device *)getDevice:(UInt32)uid;
- (void)addDevice:(Device *)device uid:(UInt32)uid;
- (void)setName:(UInt32)uid name:(NSString*)name;
- (NSString *)getName:(UInt32)uid;
- (NSMutableArray *)getDevicesArray;
- (Device *)getSelectedDevice;
@end

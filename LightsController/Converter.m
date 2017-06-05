//
//  Converter.m
//  LightsController
//
//  Created by JaredLee on 6/1/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import "Converter.h"

@implementation Converter

+ (UInt32)byteArrayToInt:(Byte *)bytes
{
    return ((bytes[0] & 0xFF) |
    (bytes[1] & 0xFF) << 8 |
    (bytes[2] & 0xFF) << 16 |
    (bytes[3] & 0xFF) << 24);
    
}
+ (void)intToByteArray:(UInt32)vaule Bytes:(Byte *)bytes
{
    bytes[0] = (Byte)(vaule&0xff);
    bytes[1] = (Byte)((vaule>>8)&0xff);
    bytes[2] = (Byte)((vaule>>16)&0xff);
    bytes[3] = (Byte)((vaule>>24)&0xff);
    
}
+ (Byte *)combineTo:(Byte *)bytes header:(UInt32)header id:(UInt32)uid brightness:(Byte)brightness status:(Byte)status
{
    bytes[0] = (Byte)(header&0xff);
    bytes[1] = (Byte)((header>>8)&0xff);
    bytes[2] = (Byte)((header>>16)&0xff);
    bytes[3] = (Byte)((header>>24)&0xff);
    bytes[4] = (Byte)(uid&0xff);
    bytes[5] = (Byte)((uid>>8)&0xff);
    bytes[6] = (Byte)((uid>>16)&0xff);
    bytes[7] = (Byte)((uid>>24)&0xff);
    bytes[8] = status;
    bytes[9] = brightness;
    bytes[10] = (Byte) (bytes[0] & bytes[2] & bytes[4] & bytes[6] & bytes[8]);
    bytes[11] = (Byte) (bytes[1] | bytes[3] | bytes[5] | bytes[7] | bytes[9]);
    return bytes;
}
@end

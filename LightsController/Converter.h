//
//  Converter.h
//  LightsController
//
//  Created by JaredLee on 6/1/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Converter : NSObject
+ (UInt32)byteArrayToInt:(Byte *)bytes;
+ (void)intToByteArray:(UInt32)vaule Bytes:(Byte *)bytes;
+ (Byte *)combineTo:(Byte *)bytes header:(UInt32)header id:(UInt32)id brightness:(Byte)brightness status:(Byte)status;
@end

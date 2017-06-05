//
//  Device.h
//  LightsController
//
//  Created by JaredLee on 6/1/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject{

@public
    NSString *name;
    UInt32 uid;
    Byte brightness;
    Byte status;

}

@end

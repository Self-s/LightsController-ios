//
//  ViewController.h
//  LightsController
//
//  Created by JaredLee on 5/16/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
- (void)udpData:(Byte *)data;
@end


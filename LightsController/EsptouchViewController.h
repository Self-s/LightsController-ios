//
//  EsptouchViewController.h
//  LightsController
//
//  Created by JaredLee on 6/1/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EsptouchViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (strong, nonatomic) NSString *bssid;
@end

//
//  DevicesTableViewCell.h
//  LightsController
//
//  Created by JaredLee on 6/1/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end

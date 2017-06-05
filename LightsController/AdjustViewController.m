//
//  AdjustViewController.m
//  LightsController
//
//  Created by JaredLee on 5/21/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import "AdjustViewController.h"
#import "UdpSocket.h"
#import "Converter.h"
#define ADJUST 0xAAAAAAAA
@interface AdjustViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *bulbStatus;
@property (weak, nonatomic) IBOutlet UIImageView *bulbSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *devicesList;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (strong, nonatomic) Device *dev;
@end

@implementation AdjustViewController

- (IBAction)brightnessChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if(slider.value<50)
        _bulbStatus.image = [UIImage imageNamed:@"on_p1"];
    else if (slider.value<90)
        _bulbStatus.image = [UIImage imageNamed:@"on_p50"];
    else _bulbStatus.image = [UIImage imageNamed:@"on_p100"];
    Byte data[12]={0};
    [[UdpSocket sharedSocketManager] sendData:[Converter combineTo:data header:ADJUST id:_dev->uid brightness:slider.value status:0xff]];
}
- (IBAction)devicesListBtnTap:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)bulbSwitchBtnTap:(id)sender{
    if(_brightnessSlider.hidden == NO){
        _brightnessSlider.hidden = YES;
        _bulbStatus.image = [UIImage imageNamed:@"off"];
        Byte data[12]={0};
        [[UdpSocket sharedSocketManager] sendData:[Converter combineTo:data header:ADJUST id:_dev->uid brightness:0x00 status:0x00]];
    }else{
        UInt32 brightness = _brightnessSlider.value;
        if(brightness < 20) brightness = 20;
        _brightnessSlider.hidden = NO;
        if(_brightnessSlider.value<50)
            _bulbStatus.image = [UIImage imageNamed:@"on_p1"];
        else if (_brightnessSlider.value<90)
            _bulbStatus.image = [UIImage imageNamed:@"on_p50"];
        else _bulbStatus.image = [UIImage imageNamed:@"on_p100"];
        Byte data[12]={0};
        [[UdpSocket sharedSocketManager] sendData:[Converter combineTo:data header:ADJUST id:_dev->uid brightness:brightness status:0xff]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *thumbImage = [UIImage imageNamed:@"thumb"];
    [_brightnessSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    _brightnessSlider.continuous = YES;
   
    _devicesList.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(devicesListBtnTap:)];
    [_devicesList addGestureRecognizer:singleTap];
    
    _bulbSwitch.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bulbSwitchBtnTap:)];
    [_bulbSwitch addGestureRecognizer:singleTap1];

    _dev =[[UdpSocket sharedSocketManager] getSelectedDevice];
    [_name setText:_dev->name];
    if(_dev->status == 0xff){
        _brightnessSlider.hidden = NO;
        _brightnessSlider.value = _dev->brightness;
        if(_dev->brightness<50)
            _bulbStatus.image = [UIImage imageNamed:@"on_p1"];
        else if (_dev->brightness<90)
            _bulbStatus.image = [UIImage imageNamed:@"on_p50"];
        else _bulbStatus.image = [UIImage imageNamed:@"on_p100"];
    }else {
        _brightnessSlider.hidden = YES;
        _bulbStatus.image = [UIImage imageNamed:@"off"];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"re");
    // Dispose of any resources that can be recreated.
}


@end

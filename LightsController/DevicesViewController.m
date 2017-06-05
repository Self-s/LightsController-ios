//
//  ViewController.m
//  LightsController
//
//  Created by JaredLee on 5/16/17.
//  Copyright © 2017 JaredLee. All rights reserved.
//

#import "DevicesViewController.h"
#import "AdjustViewController.h"
#import "EsptouchViewController.h"
#import "Converter.h"
#import "UdpSocket.h"
#import "Device.h"
#import "DevicesTableViewCell.h"
#define ADJUST 0xAAAAAAAA
#define ACKNOWLEDGE 0xBBBBBBBB
#define LOOKUP 0xCCCCCCCC
#define FOUND 0xDDDDDDDD
@interface DevicesViewController ()
@property (weak, nonatomic) IBOutlet UILabel *arragBy;
@property (weak, nonatomic) IBOutlet UITableView *devicesListTableView;
@property (weak, nonatomic) IBOutlet UIImageView *addDevicesBtn;

@end

@implementation DevicesViewController
- (IBAction)addDevicesBtnTap:(id)sender {
    EsptouchViewController *esptouchViewControllertrol=[self.storyboard instantiateViewControllerWithIdentifier:@"esptouchView"];
    [self presentViewController:esptouchViewControllertrol animated:YES completion:nil];
}
- (IBAction)arrangeByBtnTap:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Arrage By" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *nameAction = [UIAlertAction actionWithTitle:@"name" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _arragBy.text = @"name";
        
    }];
    
    UIAlertAction *idAction = [UIAlertAction actionWithTitle:@"id" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _arragBy.text = @"id";
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:nameAction];
    [alertController addAction:idAction];

    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)deviceCellLongPress:(UILongPressGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:_devicesListTableView];
        
        NSIndexPath * indexPath = [_devicesListTableView indexPathForRowAtPoint:point];
        
        if(indexPath == nil) return ;
        Device *dev = [[UdpSocket sharedSocketManager] getDevicesArray][indexPath.section];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change the device alias" message:nil preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *nameTextField = alertController.textFields.firstObject;
            dev->name = nameTextField.text;
            [_devicesListTableView reloadData];
            [[UdpSocket sharedSocketManager] setName:dev->uid name:nameTextField.text];

        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:nil]];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = dev->name;
        }];
        
        [self presentViewController:alertController animated:true completion:nil];
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _addDevicesBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addDevicesBtnTap:)];
    [_addDevicesBtn addGestureRecognizer:singleTap];
    
    _arragBy.userInteractionEnabled = YES;
    _arragBy.layer.borderWidth = 1;
    _arragBy.layer.borderColor = [[UIColor colorWithRed:0.9450980392f green:0.3568627451f blue:0.168627451f alpha:1.0f] CGColor];
    UITapGestureRecognizer *singleTap1 =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arrangeByBtnTap:)];
    [_arragBy addGestureRecognizer:singleTap1];
    
    _devicesListTableView.dataSource = self;
    _devicesListTableView.delegate = self;
    _devicesListTableView.rowHeight = 65;
    _devicesListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_devicesListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _devicesListTableView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deviceCellLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [_devicesListTableView addGestureRecognizer:longPress];
    
    [[UdpSocket sharedSocketManager] setDevicesViewController:self];
    Byte data[12]={0};
    [Converter combineTo:data header:LOOKUP id:0xffffffff brightness:0xff status:0x00];
    [[UdpSocket sharedSocketManager] sendData:data];
    [[UdpSocket sharedSocketManager] sendData:data];
    [[UdpSocket sharedSocketManager] sendData:data];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)udpData:(Byte *)data{
    UInt32 uid = [Converter byteArrayToInt:data+4];
    Device *dev = [[UdpSocket sharedSocketManager] getDevice:uid];
    Byte brightness = data[9];
    Byte status = data[8];
    switch ([Converter byteArrayToInt:data]) {
        case ACKNOWLEDGE:
            if(dev == nil){
                Device *d = [Device alloc];
                NSString *name = [[UdpSocket sharedSocketManager] getName:uid];
                if(!name){
                    d->name = [NSString stringWithFormat:@"%d Not named yet",uid];
                }else{
                    d->name = name;
                }
                d->uid = uid;
                d->brightness = brightness;
                d->status = status;
                [[UdpSocket sharedSocketManager] addDevice:d uid:uid];
            }
            else{
                dev->brightness = brightness;
                dev->status = status;
            }
            [_devicesListTableView reloadData];
            break;
        case FOUND:
            if(dev == nil){
                Device *d = [Device alloc];
                NSString *name = [[UdpSocket sharedSocketManager] getName:uid];
                if(!name){
                    d->name = [NSString stringWithFormat:@"%d Not named yet",uid];
                }else{
                    d->name = name;
                }
                d->uid = uid;
                d->brightness = brightness;
                d->status = status;
                [[UdpSocket sharedSocketManager] addDevice:d uid:uid];
            }
            else{
                dev->brightness = brightness;
                dev->status = status;
            }
            [_devicesListTableView reloadData];
            break;
        default:
            break;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[UdpSocket sharedSocketManager] getDevicesArray] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"devicesCell";
    DevicesTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[DevicesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    Device *device = [[UdpSocket sharedSocketManager] getDevicesArray][indexPath.row];
    cell.nameLabel.text=device->name;
    if(device->status == 0xff)
        cell.statusImageView.image=[UIImage imageNamed:@"status_on"];
    else
        cell.statusImageView.image=[UIImage imageNamed:@"status_off"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UdpSocket sharedSocketManager]->selected = indexPath.section;
    [_devicesListTableView deselectRowAtIndexPath:indexPath animated:YES];
    AdjustViewController *adjustViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"adjustView"];
    [self presentViewController:adjustViewController animated:YES completion:nil];
}
@end

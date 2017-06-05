//
//  EsptouchViewController.m
//  EspTouchDemo
//
//  Created by 白 桦 on 3/23/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import "EsptouchViewController.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"

#import <SystemConfiguration/CaptiveNetwork.h>

// the three constants are used to hide soft-keyboard when user tap Enter or Return
#define HEIGHT_KEYBOARD 216
#define HEIGHT_TEXT_FIELD 30
#define HEIGHT_SPACE (6+HEIGHT_TEXT_FIELD)


@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl


-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *ipAddrDataStr = [ESP_NetUtil descriptionInetAddr4ByData:result.ipAddrData];
    if (ipAddrDataStr==nil) {
        ipAddrDataStr = [ESP_NetUtil descriptionInetAddr6ByData:result.ipAddrData];
    }
     NSString *message = [NSString stringWithFormat:@"%@ is connected to the wifi" , ipAddrDataStr];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connected" message:message delegate:nil cancelButtonTitle:@"I know" otherButtonTitles:nil];
    [alertView show];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithResult:result];
    });
}

@end

@interface EsptouchViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *devicesList;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *_spinner;
@property (weak, nonatomic) IBOutlet UITextField *_pwdTextView;

@property (weak, nonatomic) IBOutlet UIButton *_confirmCancelBtn;

// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

// the state of the confirm/cancel button
@property (nonatomic, assign) BOOL _isConfirmState;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *_condition;

@property (nonatomic, strong) UIButton *_doneButton;
@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;
@end

@implementation EsptouchViewController

- (IBAction)devicesListBtn:(id)sender{
    if(self._isConfirmState == NO) [self cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapConfirmCancelBtn:(UIButton *)sender
{
    [self tapConfirmForResult];
}


- (void) tapConfirmForResult
{
    if (self._isConfirmState)
    {
        if (_ssidLabel.text==nil||[_ssidLabel.text isEqualToString:@""])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops" message:@"\r\nWIFI SSID shouldn't be null or empty! \r\n\r\nMake sure your phone is connected to wifi." preferredStyle: UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"I know" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self._spinner startAnimating];
        [self enableCancelBtn];
        NSLog(@"EsptouchViewController do confirm action...");
        dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSLog(@"EsptouchViewController do the execute work...");
            // execute the task
            ESPTouchResult *esptouchResult = [self executeForResult];
            // show the result to the user in UI Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self._spinner stopAnimating];
                [self enableConfirmBtn];
                // when canceled by user, don't show the alert view again
                if (!esptouchResult.isCancelled)
                {
                    if(esptouchResult.isSuc == NO){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Failed!" message:nil preferredStyle: UIAlertControllerStyleAlert];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"I know" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                }
            });
        });
    }
    // do cancel
    else
    {
        [self._spinner stopAnimating];
        [self enableConfirmBtn];
        NSLog(@"EsptouchViewController do cancel action...");
        [self cancel];
    }
}

#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}

- (ESPTouchResult *) executeForResult
{
    [self._condition lock];
    NSString *apSsid = self.ssidLabel.text;
    NSString *apPwd = self._pwdTextView.text;
    NSString *apBssid = self.bssid;
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._condition unlock];
    ESPTouchResult * esptouchResult = [self._esptouchTask executeForResult];
    NSLog(@"EsptouchViewController executeForResult() result is: %@",esptouchResult);
    return esptouchResult;
}


// enable confirm button
- (void)enableConfirmBtn
{
    self._isConfirmState = YES;
    [self._confirmCancelBtn setTitle:@"Confirm" forState:UIControlStateNormal];
}

// enable cancel button
- (void)enableCancelBtn
{
    self._isConfirmState = NO;
    [self._confirmCancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *netInfo = [self fetchNetInfo];
    _ssidLabel.text = [netInfo objectForKey:@"SSID"];
    _bssid = [netInfo objectForKey:@"BSSID"];
    _devicesList.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(devicesListBtn:)];
    [_devicesList addGestureRecognizer:singleTap];
    self._isConfirmState = NO;
    self._pwdTextView.delegate = self;
    self._pwdTextView.keyboardType = UIKeyboardTypeASCIICapable;
    self._condition = [[NSCondition alloc]init];
    self._esptouchDelegate = [[EspTouchDelegateImpl alloc]init];
    [self enableConfirmBtn];
}

#pragma mark - the follow codes are just to make soft-keyboard disappear at necessary time

// when out of pwd textview, resign the keyboard
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self._pwdTextView isExclusiveTouch])
    {
        [self._pwdTextView resignFirstResponder];
    }
   
}

#pragma mark -  the follow three methods are used to make soft-keyboard disappear when user finishing editing

// when textField begin editing, soft-keyboard apeear, do the callback
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y - (self.view.frame.size.height - (HEIGHT_KEYBOARD+HEIGHT_SPACE));
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if(offset > 0)
    {
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
}

// when user tap Enter or Return, disappear the keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// when finish editing, make view restore origin state
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) addButtonToKeyboard {
    // create custom button
    if (self._doneButton == nil) {
        self._doneButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 163, 106, 53)];
    }
    else {
        [self._doneButton setHidden:NO];
    }
    
    [self._doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard = nil;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard found, add the button
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:self._doneButton];
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:self._doneButton];
        }
    }
}

- (void) doneButtonClicked:(id)Sender {
    //Write your code whatever you want to do on done button tap
    //Removing keyboard or something else
    
}
- (NSString *)fetchSsid
{
    NSDictionary *ssidInfo = [self fetchNetInfo];
    
    return [ssidInfo objectForKey:@"SSID"];
}

- (NSString *)fetchBssid
{
    NSDictionary *bssidInfo = [self fetchNetInfo];
    
    return [bssidInfo objectForKey:@"BSSID"];
}

// refer to http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}


@end


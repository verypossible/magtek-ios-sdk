//
//  MTDataViewerViewController.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "MTDataViewerViewController.h"
#import "NSObject+TLVParser.h"
#import <MediaPlayer/MediaPlayer.h>

#define SHOW_DEBUG_COUNT 0

@interface MTDataViewerViewController ()
{
    int swipeCount;
    NSString* commandResult;
}
@end

@implementation MTDataViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void) setUpUI
{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear Data"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(clearData)];
    
    _btnConnect = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 98 - 65, self.view.frame.size.width, 50)];
    [_btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [_btnConnect setBackgroundColor:UIColorFromRGB(0x3465AA)];
    [_btnConnect addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    
    
    _txtData = [[UITextView alloc]initWithFrame:CGRectMake(5, 60, self.view.frame.size.width - 10, self.view.frame.size.height - 240)];
    _txtData.backgroundColor = UIColorFromRGB(0x667788);
    _txtData.textColor = UIColorFromRGB(0xffffff);
    [_txtData setEditable:NO];
    
    _txtCommand = [[UITextField alloc]initWithFrame:CGRectMake(5 , 9, self.view.frame.size.width - 90, 40)];
    _txtCommand.delegate = self;
    _txtCommand.backgroundColor = UIColorFromRGB(0xdddddd);
    _txtCommand.placeholder = @"Send Command";
    
    
    _txtCommand.text = @""; // Extended Command ECHO
    
    
    _btnSendCommand =  [[UIButton alloc]initWithFrame:CGRectMake(_txtCommand.frame.origin.x + _txtCommand.frame.size.width + 5 , 9, 75, 40)];
    [_btnSendCommand setTitle:@"Send" forState:UIControlStateNormal];
    [_btnSendCommand addTarget:self action:@selector(sendCommand) forControlEvents:UIControlEventTouchUpInside];
    [_btnSendCommand setBackgroundColor:UIColorFromRGB(0x3465AA)];
    
    [self.view addSubview:_txtCommand];
    [self.view addSubview:_txtData];
    [self.view addSubview:_btnSendCommand];
    
    [self.view addSubview:_btnConnect];
    
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)sendCommand
{
    if (_txtCommand.text.length > 0) {
        [self.lib sendcommandWithLength:_txtCommand.text];
    }
}

- (void)connect
{
    if(!self.lib.isDeviceOpened )
    {
        self.txtData.text = @"Connecting...";
        [self.lib openDevice];
    }
    else
    {
        [self.lib closeDevice];
    }
    
    if(self.lib.getDeviceType == MAGTEKAUDIOREADER)
    {
        // ...
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        musicPlayer.volume = 1.0f;
    }
#if SHOW_DEBUG_COUNT
    swipeCount = 0;
#endif
}

- (void) cardSwipeDidStart:(id)instance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}
- (void) cardSwipeDidGetTransError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.txtData.text = @"Transfer error...";
    });
}


-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.lib isDeviceOpened])
        {
            if([self.lib isDeviceConnected])
            {
                
                [_btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
                [self.btnConnect setBackgroundColor:UIColorFromRGB(0xcc3333)];
            }
            else
            {
                
                
                [_btnConnect setTitle: @"Connect" forState:UIControlStateNormal];
                [self.btnConnect setBackgroundColor:UIColorFromRGB(0x3465AA)];
            }
        }
        else
        {
            
            
            [_btnConnect setTitle: @"Connect" forState:UIControlStateNormal];
            
            [self.btnConnect setBackgroundColor:UIColorFromRGB(0x3465AA)];
        }
        
    });
    
}

- (void)onDeviceError:(NSError *)error
{
    self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text, error.localizedDescription];// @"Connected...";
}
-(void) onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL)connected instance:(id)instance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([(MTSCRA*)instance isDeviceOpened])
        {
            if(connected)
            {
                self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text, @"Connected..."];// @"Connected...";
                if(deviceType == MAGTEKDYNAMAX || deviceType == MAGTEKEDYNAMO)
                {
                    self.txtData.text = [self.txtData.text stringByAppendingString:[(MTSCRA*)instance getConnectedPeripheral].name];
                    if(deviceType == MAGTEKEDYNAMO)
                    {
                        [self.lib sendcommandWithLength:@"480101"]; //Make sure device is in BLE Output mode.
                        
                    }
                    else if(deviceType == MAGTEKDYNAMAX)
                    {
                        [self.lib sendcommandWithLength:@"000101"];
                    }
                    
                }
                [_btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
                [self.btnConnect setBackgroundColor:UIColorFromRGB(0xcc3333)];
            }
            else
            {
                
                self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text, @"Disconnected"];
                [_btnConnect setTitle: @"Connect" forState:UIControlStateNormal];
                [self.btnConnect setBackgroundColor:UIColorFromRGB(0x3465AA)];
            }
        }
        else
        {
            
            // self.txtData.text = @"Disconnected";
            self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text, @"Disconnected"];
            [_btnConnect setTitle: @"Connect" forState:UIControlStateNormal];
            
            [self.btnConnect setBackgroundColor:UIColorFromRGB(0x3465AA)];
        }
#if SHOW_DEBUG_COUNT
        self.txtData.text = [self.txtData.text stringByAppendingString: [NSString stringWithFormat:@"\n\nSwipe.Count:%i", swipeCount]];
#endif
    });
    
}
-(void)clearData
{
    [self.lib clearBuffers];
    [self.txtData setText:@""];
}




-(void)onDataReceived:(MTCardData *)cardDataObj instance:(id)instance
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.txtData.text =  [NSString stringWithFormat:
                              @"Track.Status: %@\n\n"
                              "Track1.Status: %@\n\n"
                              "Track2.Status: %@\n\n"
                              "Track3.Status: %@\n\n"
                              "Encryption.Status: %@\n\n"
                              "Battery.Level: %ld\n\n"
                              "Swipe.Count: %ld\n\n"
                              "Track.Masked: %@\n\n"
                              "Track1.Masked: %@\n\n"
                              "Track2.Masked: %@\n\n"
                              "Track3.Masked: %@\n\n"
                              "Track1.Encrypted: %@\n\n"
                              "Track2.Encrypted: %@\n\n"
                              "Track3.Encrypted: %@\n\n"
                              "Card.PAN: %@\n\n"
                              "MagnePrint.Encrypted: %@\n\n"
                              "MagnePrint.Length: %i\n\n"
                              "MagnePrint.Status: %@\n\n"
                              "SessionID: %@\n\n"
                              "Card.IIN: %@\n\n"
                              "Card.Name: %@\n\n"
                              "Card.Last4: %@\n\n"
                              "Card.ExpDate: %@\n\n"
                              "Card.ExpDateMonth: %@\n\n"
                              "Card.ExpDateYear: %@\n\n"
                              "Card.SvcCode: %@\n\n"
                              "Card.PANLength: %ld\n\n"
                              "KSN: %@\n\n"
                              "Device.SerialNumber: %@\n\n"
                              "MagTek SN: %@\n\n"
                              "Firmware Part Number: %@\n\n"
                              "Device Model Name: %@\n\n"
                              "TLV Payload: %@\n\n"
                              "DeviceCapMSR: %@\n\n"
                              "Operation.Status: %@\n\n"
                              "Card.Status: %@\n\n"
                              "Raw Data: \n\n%@",
                              cardDataObj.trackDecodeStatus,
                              cardDataObj.track1DecodeStatus,
                              cardDataObj.track2DecodeStatus,
                              cardDataObj.track3DecodeStatus,
                              cardDataObj.encryptionStatus,
                              cardDataObj.batteryLevel,
                              cardDataObj.swipeCount,
                              cardDataObj.maskedTracks,
                              cardDataObj.maskedTrack1,
                              cardDataObj.maskedTrack2,
                              cardDataObj.maskedTrack3,
                              cardDataObj.encryptedTrack1,
                              cardDataObj.encryptedTrack2,
                              cardDataObj.encryptedTrack3,
                              cardDataObj.cardPAN,
                              cardDataObj.encryptedMagneprint,
                              cardDataObj.magnePrintLength,
                              cardDataObj.magneprintStatus,
                              cardDataObj.encrypedSessionID,
                              cardDataObj.cardIIN,
                              cardDataObj.cardName,
                              cardDataObj.cardLast4,
                              cardDataObj.cardExpDate,
                              cardDataObj.cardExpDateMonth,
                              cardDataObj.cardExpDateYear,
                              cardDataObj.cardServiceCode,
                              cardDataObj.cardPANLength,
                              cardDataObj.deviceKSN,
                              cardDataObj.deviceSerialNumber,
                              cardDataObj.deviceSerialNumberMagTek,
                              cardDataObj.firmware,
                              cardDataObj.deviceName,
                              [(MTSCRA*)instance getTLVPayload],
                              cardDataObj.deviceCaps,
                              [(MTSCRA*)instance getOperationStatus],
                              cardDataObj.cardStatus,
                              [(MTSCRA*)instance getResponseData]];
        
    });
    
    NSLog(@"%@", self.txtData.text);
    
}



- (NSString *)getHexString:(NSData *)data
{
    
    
    NSMutableString *mutableStringTemp = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < data.length; i++)
    {
        unsigned char tempByte;
        
        [data getBytes:&tempByte
                 range:NSMakeRange(i, 1)];
        
        [mutableStringTemp appendFormat:@"%02X", tempByte];
    }
    
    return mutableStringTemp;
}

-(void)onDeviceResponse:(NSData *)data
{
    
    
    NSString* dataString = [self getHexString:data];
    
    
    commandResult = dataString;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.txtData.text = [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[Device Response]\n%@", dataString]];
    });
    
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

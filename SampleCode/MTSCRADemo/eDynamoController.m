//
//  eDynamoController.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/22/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "eDynamoController.h"
#import "eDynamoSignature.h"

#define ARQC_DYNAPRO_FORMAT 0x01
#define ARQC_EDYNAMO_FORMAT 0x00
@interface eDynamoController ()
{
    UIActionSheet *userSelection;
    NSTimer* tmrTimeout;
    optionController* opt;
    Byte tempAmount[6];
    unsigned char amount[6];
    Byte currencyCode[2];
    Byte cashBack[6];
    Byte arqcFormat;
}
typedef void(^commandCompletion)(NSString*);
@property (nonatomic, strong) commandCompletion queueCompletion;
@end

@implementation eDynamoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"eDynamo";
    self.txtData.frame = CGRectMake(5, 60, self.view.frame.size.width - 10, self.view.frame.size.height - 300);
    
    int btnWidth = self.view.frame.size.width / 4;
    
    _btnStartEMV = [[UIButton alloc]initWithFrame:CGRectMake(5, self.view.frame.size.height - 98 - 65 - 60, btnWidth - 7, 40)];
    [_btnStartEMV setTitle:@"Start" forState:UIControlStateNormal];
    [_btnStartEMV setBackgroundColor:UIColorFromRGB(0x3465AA)];
    [_btnStartEMV addTarget:self action:@selector(startEMV) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnStartEMV];
    
    _btnGetStatus = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth, self.view.frame.size.height - 98 - 65 - 60, btnWidth - 2, 40)];
    [_btnGetStatus setTitle:@"Cancel" forState:UIControlStateNormal];
    [_btnGetStatus setBackgroundColor:UIColorFromRGB(0xCC3333)];
    [_btnGetStatus addTarget:self action:@selector(cancelEMV) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnGetStatus];
    
    
    _btnGetStatus = [[UIButton alloc]initWithFrame:CGRectMake((btnWidth * 2), self.view.frame.size.height - 98 - 65 - 60, btnWidth - 2, 40)];
    [_btnGetStatus setTitle:@"Reset" forState:UIControlStateNormal];
    [_btnGetStatus setBackgroundColor:UIColorFromRGB(0xCC3333)];
    [_btnGetStatus addTarget:self action:@selector(resetDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnGetStatus];
    
    
    _btnGetStatus = [[UIButton alloc]initWithFrame:CGRectMake((btnWidth * 3), self.view.frame.size.height - 98 - 65 - 60, btnWidth - 2, 40)];
    [_btnGetStatus setTitle:@"Options" forState:UIControlStateNormal];
    [_btnGetStatus setBackgroundColor:UIColorFromRGB(0xFF9900)];
    [_btnGetStatus addTarget:self action:@selector(presentOption) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnGetStatus];
    
    self.lib = [MTSCRA new];
    //self.lib.delegate = self;
    
    [self.lib setDeviceType:MAGTEKEDYNAMO];
    
    
    [self.btnConnect removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnConnect addTarget:self action:@selector(scanForBLE) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.txtData.text = [NSString stringWithFormat:@"App Version: %@.%@ , SDK Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], self.lib.getSDKVersion];
    
    
    self.lib.delegate = self;
    [self.navigationController popViewControllerAnimated:YES];
    opt = [[optionController alloc]initWithStyle:UITableViewStyleGrouped];
    
    
}


-(void)presentOption
{
    if(!opt)
        opt = [[optionController alloc]initWithStyle:UITableViewStyleGrouped];
    opt.delegate = self;
    [self.navigationController pushViewController:opt animated:YES];
    
}

-(void)getTerminalConfiguration:(NSData*)commandIn
{
    NSString* command = @"0306";
    NSString* length = @"0003";
    NSString* slotNumber = @"01";
    NSString* operation = @"0F";
    NSString* databaseSelector = @"00";
 
    
    [self.lib sendExtendedCommand:[NSString stringWithFormat:@"%@%@%@%@%@", command, length, slotNumber, operation, databaseSelector]];
}

-(void)commitConfiguration
{
    NSString* command = @"030E"; // Commit Configuration Command
    
    NSString* databaseSelector = @"00"; // Contact L2 EMV
    NSString* length = @"0001";
    
    [self.lib sendExtendedCommand:[NSString stringWithFormat:@"%@%@%@", command, length, databaseSelector]];
}

- (void)setTerminalConfiguration:(NSData*)commandIn
{
    NSString* command = @"0305";
    NSString* serialNumber = @"42324645304542303932393135414100"; //CHANGE TO REAL DEVICE SERIAL NUMBER
    NSString* macType = @"00";
    NSString* slotNumber = @"01";
    NSString* operation =  @"01";
    NSString* databaseSelector =  @"00";
    NSString* objectsToWrite = @"FA00";
    NSString* MAC = @"00000000";//PASS IN VALID MAC
    NSString* length = @"001A"; //two byte length
    [self.lib sendExtendedCommand:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", command, length, macType, slotNumber, operation, databaseSelector, serialNumber, objectsToWrite, MAC]];
    
}

- (void)didSelectConfigCommand:(NSData *)command
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if(memcmp([ [command subdataWithRange:NSMakeRange(1, 1)] bytes],"\x05",1) == 0)
    {
        [self setTerminalConfiguration:command];
    }
    else  if(memcmp([ [command subdataWithRange:NSMakeRange(1, 1)] bytes],"\x06",1) == 0)
    {
        [self getTerminalConfiguration:command];
    }
    else  if(memcmp([ [command subdataWithRange:NSMakeRange(1, 1)] bytes],"\x0e",1) == 0)
    {
        [self commitConfiguration];
    }
    
}

-(void)resetDevice
{
    [self.lib sendcommandWithLength:@"020100"];
}

- (void) cancelEMV
{
   // [self ledON:0 completion:^(NSString * status) {
        [self.lib cancelTransaction];
   // }];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    //[self.lib closeDevice];
    
}

-(void)didSelectBLEReader:(CBPeripheral *)per
{
    dispatch_async(dispatch_get_main_queue(), ^{
          self.txtData.text = @"Connecting...";
        //cbper = per;
        self.lib.delegate = self;
        [self.navigationController popViewControllerAnimated:YES];
        [self.lib setUUIDString:per.identifier.UUIDString];
        [self.lib openDevice];
    });
    
}
-(void)bleReaderStateUpdated:(MTSCRABLEState)state
{
    

    
    NSLog(@"BLE State: %d", state);
    
    if(state == UNSUPPORTED)
    {
        [[[UIAlertView alloc]initWithTitle:@"BLE Error" message:@"BLE is unsupported on this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        
    }
}
- (void)scanForBLE
{
    
    if(self.lib.isDeviceOpened)
    {
        [self.lib closeDevice];
        return;
    }
    
    BLEScannerList* list = [[BLEScannerList alloc] initWithStyle:UITableViewStylePlain lib:self.lib];
    list.delegate = self;
    [self.navigationController pushViewController:list animated:YES];
}



//-(NSData *)reverseData:(NSData*)dataIn
//{
//    NSMutableData *data = [[NSMutableData alloc] init];
//    for(int i = (int)dataIn.length - 1; i >=0; i--){
//        [data appendBytes: &dataIn.bytes[i] length:1];
//    }
//    return [data copy];
//}
//
//
//- (NSString *) cleanNonHexCharsFromHexString:(NSString *)input
//{
//    if (input == nil) {
//        return nil;
//        
//    }
//    
//    NSString * output = [input stringByReplacingOccurrencesOfString:@"0x" withString:@""
//                                                            options:NSCaseInsensitiveSearch range:NSMakeRange(0, input.length)];
//    NSString * hexChars = @"-0123456789abcdefABCDEF";
//    NSCharacterSet *hexc = [NSCharacterSet characterSetWithCharactersInString:hexChars];
//    NSCharacterSet *invalidHexc = [hexc invertedSet];
//    NSString * allHex = [[output componentsSeparatedByCharactersInSet:invalidHexc] componentsJoinedByString:@""];
//    return allHex;
//}
//
//
//- (NSData *) dataFromHexString:(NSString*)stringIn
//{
//    stringIn = [NSString stringWithFormat:@"%.02f",stringIn.doubleValue];
//    
//    if ([stringIn rangeOfString:@"."].location == NSNotFound) {
//        stringIn = [stringIn stringByAppendingString:@".00"];
//    }
//    
//    
//    
//    NSString * cleanString = [self cleanNonHexCharsFromHexString:stringIn];
//    if (cleanString == nil) {
//        return nil;
//    }
//    
//    if(cleanString.length % 2)
//    {
//        cleanString = [NSString stringWithFormat:@"0%@", cleanString];
//    }
//    
//    
//    NSMutableData *result = [[NSMutableData alloc] init];
//    
//    int i = 0;
//    for (i = 0; i+2 <= cleanString.length; i+=2) {
//        NSRange range = NSMakeRange(i, 2);
//        NSString* hexStr = [cleanString substringWithRange:range];
//        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
//        unsigned int intValue;
//        [scanner scanHexInt:&intValue];
//        unsigned char uc = (unsigned char) intValue;
//        [result appendBytes:&uc length:1];
//    }
//    NSData * data = [NSData dataWithData:result];
//    //[result release];
//    return [self reverseData:data];
//}
//

- (void)deviceNotPaired
{
    self.txtData.text = @"Error: Device not Paired.";
    
}
-(void) onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL)connected instance:(id)instance
{
    [super onDeviceConnectionDidChange:deviceType connected:connected instance:instance];
    
    
    
}





- (int)getARQCFormat: (commandCompletion)completion
{
    
    int rs = [self.lib sendcommandWithLength:@"000168"];
    if(rs == 0)
    {
        self.queueCompletion = completion;
    }
    //0 - sent successful
    //15 - device is busy
    return rs;
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *txtAmount = [alertView textFieldAtIndex:0].text;
        if(txtAmount.length == 0)
            txtAmount = @"0";
        if(txtAmount.length > 0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if(alertView.tag == 0)
                {
                    NSData* dataAmount = [HexUtil dataFromHexString:txtAmount];
                    
                    
                    memcpy(tempAmount, [dataAmount bytes],6);
                    
                    for (int i = 5; i >= 0; i--) {
                        amount[i] = tempAmount[5 - i];
                    }
                    memcpy(tempAmount, amount,6);
                    
                }
                else
                {
                    memcpy(amount, tempAmount,6);
                    
                }
                Byte timeLimit = 0x3C;
                Byte cardType = 0x02;
                Byte option = 0x00;
                
                Byte transactionType = [opt getPurchaseOption];
                //Byte cashBack[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
                
                cashBack[0] = 0x00;
                cashBack[1] = 0x00;
                cashBack[2] = 0x00;
                cashBack[3] = 0x00;
                cashBack[4] = 0x00;
                cashBack[5] = 0x00;
                
                
                currencyCode[0] =  0x08;
                currencyCode[1] = 0x40;
                Byte reportingOption = [opt getReportingOption];
                
                
                if([opt getPurchaseOption] & 0x02)
                {
                    if(alertView.tag != 1)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Cashback Amount"
                                                                            message:@"Enter amout for Cashback"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Cancel"
                                                                  otherButtonTitles:@"OK", nil];
                            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                            [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
                            alert.tag = 1;
                            [alert show];
                            
                        });
                        return;
                    }
                    else
                    {
                        NSData* dataAmount = [HexUtil dataFromHexString:txtAmount];
                        
                        
                        memcpy(tempAmount, [dataAmount bytes],6);
                        
                        for (int i = 5; i >= 0; i--) {
                            cashBack[i] = tempAmount[5 - i];
                        }
                        
                        
                    }
                    
                    
                }
                [self getARQCFormat:^(NSString *format) {
                    
                    if([[format substringToIndex:1] isEqualToString:@"02"])
                    {
                        arqcFormat = 0x00;
                    }
                    else
                    {
                        if([HexUtil getBytesFromHexString:format].length > 2)
                        {
                            NSData * data = [[HexUtil getBytesFromHexString:format]subdataWithRange:NSMakeRange(2, 1)];
                            [data getBytes:&arqcFormat length:1];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self ledON:1 completion:^(NSString* status) {
                            [self.lib startTransaction:timeLimit cardType:cardType option:option amount:amount transactionType:transactionType cashBack:cashBack currencyCode:currencyCode reportingOption:reportingOption];
                            
                        //}];
                    });
                }];
            });
        }
        
        

    }
}

//setLED:(BOOL)
-(int)ledON:(int)on completion:(commandCompletion)completion
{
    int rs = [self.lib sendcommandWithLength:[NSString stringWithFormat: @"4D010%i", on]];
    if(rs == 0)
    {
        self.queueCompletion = completion;
    }
    //0 - sent successful
    //15 - device is busy
    return rs;
}
-(void)onDeviceResponse:(NSData *)data
{
    [super onDeviceResponse:data];
    if (self.queueCompletion) {
        self.queueCompletion([super getHexString:data]);
        self.queueCompletion = nil;
    }
}
- (void)startEMV
{
    if(self.lib.isDeviceOpened)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter amount"
                                                        message:@"Enter amount for transaction"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
        alert.tag = 0;
        [alert show];
        
        
    }
}


- (void)onDeviceError:(NSError *)error
{
    [super onDeviceError:error];
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




-(void)OnTransactionStatus:(NSData *)data
{
    NSString* dataString = [self getHexString:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.txtData.text = [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[Transaction Status]\n%@", dataString]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Transaction Status]\n%@", dataString]];
    });
    
}

-(void)OnDisplayMessageRequest:(NSData *)data
{
    NSString* dataString =  [ HexUtil stringFromHexString:[self getHexString:data]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // self.txtData.text =  [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[Display Message Request]\n%@", dataString]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Display Message Request]\n%@", dataString]];
    });
    
}

-(NSString*)getUserFriendlyLanguage:(NSString*)codeIn
{
    NSDictionary* lanCode = @{@"EN": @"English",
                              @"DE": @"Deutsch",
                              @"FR": @"Français",
                              @"ES": @"Español",
                              @"ZH": @"中文",
                              @"IT": @"Italiano"};
    
    return [lanCode objectForKey:[codeIn uppercaseString]];
}

-(void)onDeviceExtendedResponse:(NSString *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        //self.txtData.text =  [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[Device Extended Response]\n%@", data]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Device Extended Response]\n%@", data]];
    });
}


-(void)OnEMVCommandResult:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString* dataString = [self getHexString:data];
        //self.txtData.text =  [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[EMV Command Result]\n%@", dataString]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[EMV Command Result]\n%@", dataString]];
    });
}
-(void)OnUserSelectionRequest:(NSData *)data
{
  
    NSString* dataString = [self getHexString:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.txtData.text =  [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[User Selection Request]\n%@", dataString]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[User Selection Request]\n%@", dataString]];
        
        NSData* data = [HexUtil getBytesFromHexString:dataString];
        Byte *dataType = (unsigned char*)[[data subdataWithRange:NSMakeRange(0, 1)] bytes];
        
        
        Byte timeOut;
        [[data subdataWithRange:NSMakeRange(1, 1)] getBytes:&timeOut length:sizeof(timeOut)];
        
        NSArray* menuItems =   [[self getHexString:[data subdataWithRange:NSMakeRange(2, data.length - 2)]] componentsSeparatedByString:@"00"];
        userSelection = [[UIActionSheet alloc] init];
        [userSelection setTitle: [ HexUtil stringFromHexString: menuItems[0]]];
        userSelection.delegate = self;
        for(int i = 1; i < menuItems.count - 1; i ++)
        {
            if(dataType[0] & 0x01)
            {
                [userSelection addButtonWithTitle: [self getUserFriendlyLanguage:[ HexUtil stringFromHexString: menuItems[i]]]];
            }
            else
            {
                [userSelection addButtonWithTitle: [ HexUtil stringFromHexString: menuItems[i]]];
            }
        }
        [userSelection setDestructiveButtonIndex:[userSelection addButtonWithTitle:@"Cancel"]];
        [userSelection showInView:self.view];
        if((int)timeOut > 0)
        {
            int time = (int)timeOut;
            tmrTimeout = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(selectionTimedOut) userInfo:nil repeats:NO];
        }
        
    });
    
}


-(void)selectionTimedOut
{
    [userSelection dismissWithClickedButtonIndex:userSelection.destructiveButtonIndex animated:YES];
    [self.lib setUserSelectionResult:0x02 selection:(Byte)userSelection.destructiveButtonIndex];
    [[[UIAlertView alloc]initWithTitle:@"Transaction Timed Out" message:@"User took too long to enter a selection, transaction has been canceled" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles: nil]show];
}

-(void)OnARQCReceived:(NSData *)data
{
    NSString* dataString = [self getHexString:data];
    
    NSData *emvBytes = [HexUtil getBytesFromHexString:dataString];
    NSMutableDictionary* tlv = [emvBytes parseTLVData];
   // NSLog([tlv dumpTags]);
    dispatch_async(dispatch_get_main_queue(), ^{
        // self.txtData.text = [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[ARQC Received]\n%@", dataString]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[ARQC Received]\n%@", dataString]];
        if(tlv != nil)
        {
            NSString* deviceSN = [HexUtil stringFromHexString: [(MTTLV*)[tlv objectForKey:@"DFDF25"] value]];
            self.txtData.text = [self.txtData.text stringByAppendingString: [NSString stringWithFormat:@"\nSN Bytes = %@", [(MTTLV*)[tlv objectForKey:@"DFDF25"] value]]];
            self.txtData.text = [self.txtData.text stringByAppendingString: [NSString stringWithFormat:@"\nSN String = %@", deviceSN]];
            NSData* response;
            if(arqcFormat == ARQC_EDYNAMO_FORMAT)
            {
                
                response = [self buildAcquirerResponse:[HexUtil getBytesFromHexString:[(MTTLV*)[tlv objectForKey:@"DFDF25"] value]] encryptionType:nil ksn:nil approved:[opt shouldSendApprove]];
            }
            else
            {
                response = [self buildAcquirerResponse:[HexUtil getBytesFromHexString:[(MTTLV*)[tlv objectForKey:@"DFDF25"] value]] encryptionType:[HexUtil getBytesFromHexString:[(MTTLV*)[tlv objectForKey:@"DFDF55"] value]] ksn:[HexUtil getBytesFromHexString:[(MTTLV*)[tlv objectForKey:@"DFDF54"] value]] approved:[opt shouldSendApprove]];
            }
            //self.txtData.text = [self.txtData.text stringByAppendingString: [NSString stringWithFormat:@"\n[Send Respond]\n%@", [self getHexString:response]]];
            self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Send Respond]\n%@", response]];
            
            [self.lib setAcquirerResponse:(unsigned char *)[response bytes] length:(int)response.length];
        }
        
        
    });
    
}

- (NSData*) buildAcquirerResponse:(NSData*)deviceSN encryptionType:(NSData*)encryptionType ksn:(NSData*)ksn approved:(BOOL)approved
{
    
    NSMutableData* response = [[NSMutableData alloc]init];
    
    
    NSInteger lenSN = 0;
    if (deviceSN != nil)
    {
        lenSN = deviceSN.length;
    }
    
    
    Byte snTagByte[] = {(Byte)0xDF, (Byte)0xDF, 0x25, (Byte)lenSN};
    NSData* snTag = [NSData dataWithBytes:snTagByte length:4];
    
    Byte encryptionTypeTagByte[] = {(Byte)0xDF, (Byte)0xDF, 0x55, (Byte)encryptionType.length};
    NSData* encryptionTypeTag = [NSData dataWithBytes:encryptionTypeTagByte length:4];
    
    Byte ksnTagByte[] = {(Byte)0xDF, (Byte)0xDF, 0x54, (Byte)ksn.length};
    NSData* ksnTag = [NSData dataWithBytes:ksnTagByte length:4];
    
    Byte containerByte[] = { (Byte) 0xFA, 0x06, 0x70, 0x04};
    NSData* container = [NSData dataWithBytes:containerByte length:4];
    
    
    
    
    Byte approvedARCByte[] =  { (Byte) 0x8A, 0x02, 0x30, 0x30 };
    //Byte approvedARCByte[] =  { (Byte) 0x8A, 0x02, 0x5A, 0x33 };
    NSData* approvedARC = [NSData dataWithBytes:approvedARCByte length:4];
    
    Byte declinedARCByte[] = { (Byte) 0x8A, 0x02, 0x30, 0x35 };
    NSData* declinedARC = [NSData dataWithBytes:declinedARCByte length:4];
    
    Byte macPadding[] = { 0x00, 0x00,0x00,0x00,0x00,0x00,0x01,0x23, 0x45, 0x67 };
    
    unsigned long len = 2 + snTag.length + lenSN + container.length + approvedARC.length;
    
    if(arqcFormat == ARQC_DYNAPRO_FORMAT)
    {
        len += encryptionTypeTag.length + encryptionType.length + ksnTag.length + ksn.length;
    }
    Byte len1 = (Byte)((len >>8) & 0xff);
    Byte len2 = (Byte)(len & 0xff);
    
    Byte tempByte = 0xf9;
    [response appendBytes:&len1 length:1];
    [response appendBytes:&len2 length:1];
    [response appendBytes:&tempByte length:1];
    tempByte = (Byte) (len - 2);
    if(arqcFormat == ARQC_DYNAPRO_FORMAT)
    {
        tempByte = encryptionTypeTag.length + encryptionType.length + ksnTag.length + ksn.length +  snTag.length + lenSN;
    }
    [response appendBytes:&tempByte length:1];
    
    
    if(arqcFormat == ARQC_DYNAPRO_FORMAT)
    {
        [response appendData:ksnTag];
        [response appendData:ksn];
        
        [response appendData:encryptionTypeTag];
        [response appendData:encryptionType];
    }
    
    [response appendData:snTag];
    [response appendData:deviceSN];
    [response appendData:container];
    
    
    if(approved)
    {
        [response appendData:approvedARC];
    }
    else
    {
        [response appendData:declinedARC];
    }
    if(arqcFormat == ARQC_DYNAPRO_FORMAT)
    {
        
        [response appendData:[NSData dataWithBytes:&macPadding length:10]];
    }
    
    
    
    return  response;
    
}
-(void)OnTransactionResult:(NSData *)data
{
    NSString* dataString = [self getHexString:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.txtData.text =  [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n[Transaction Result]\n%@", dataString]];
        self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Transaction Result]\n%@", dataString]];
        
        
        NSString* dataString = [self getHexString:[data subdataWithRange:NSMakeRange(1, data.length - 1)]];
        
        NSData *emvBytes = [HexUtil getBytesFromHexString:dataString];
        NSMutableDictionary* tlv = [emvBytes parseTLVData];
        NSString* dataDump = [tlv dumpTags];
       // NSLog(@"%@", dataDump);
        if(arqcFormat == ARQC_EDYNAMO_FORMAT)
        {
            Byte* responseTag = (unsigned char*)[[HexUtil getBytesFromHexString:[(MTTLV*)[tlv objectForKey:@"DFDF1A"] value]]bytes] ;
            
            
            self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Parsed Transaction Result]\n%@", dataDump]];
            
            Byte *sigReq = (unsigned char*)[[data subdataWithRange:NSMakeRange(0, 1)] bytes] ;
            if(sigReq[0] == 0x01 && (responseTag[0] == 0x00))
            {
                [[[UIAlertView alloc] initWithTitle:@"Signature"
                                            message:@"Signature required, please sign."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
                eDynamoSignature* sig = [eDynamoSignature new];
                
                [self.navigationController pushViewController:sig animated:YES];
            }
            else if(!(responseTag[0] == 0x01))
            {
                [[[UIAlertView alloc] initWithTitle:@"Declined"
                                            message:@"Transaction declined, signature not required."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
            }
            else if(sigReq[0] == 0x00  && (responseTag[0] == 0x00))
            {
                [[[UIAlertView alloc] initWithTitle:@"Signature"
                                            message:@"Signature not required."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
                
            }
            
        }
        else
        {
            Byte* responseTag = (unsigned char*)[[HexUtil getBytesFromHexString:[(MTTLV*)[tlv objectForKey:@"DFDF1A"] value]]bytes] ;
            
            
            //self.txtData.text =  [self.txtData.text stringByAppendingString:[NSString stringWithFormat:@"\n\n[Parsed Transaction Result]\n%@", dataDump]];
            self.txtData.text = [NSString stringWithFormat:@"%@\r%@", self.txtData.text,[NSString stringWithFormat:@"\n[Parsed Transaction Result]\n%@", dataDump]];
            
            Byte *sigReq = (unsigned char*)[[data subdataWithRange:NSMakeRange(0, 1)] bytes] ;
            if(sigReq[0] & 0x01 && (responseTag[0] == 0x00))
            {
                [[[UIAlertView alloc] initWithTitle:@"Signature"
                                            message:@"Signature required, please sign."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
                eDynamoSignature* sig = [eDynamoSignature new];
                
                [self.navigationController pushViewController:sig animated:YES];
            }
            else if(responseTag[0] != 0x00)
            {
                [[[UIAlertView alloc] initWithTitle:@"Declined"
                                            message:@"Transaction declined, signature not required."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
            }
            else if(sigReq[0] == 0x01)
            {
                [[[UIAlertView alloc] initWithTitle:@"Signature"
                                            message:@"Signature not required."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil]show];
                
            }
            
        }
        
        
    });
    [self ledON:0 completion:nil];
}




-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (tmrTimeout) {
        [tmrTimeout invalidate];
        tmrTimeout = nil;
    }
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self.lib setUserSelectionResult:0x01 selection:0x00];
        return;
    }
    
    [self.lib setUserSelectionResult:0x00 selection:(Byte)buttonIndex];
    
}
@end

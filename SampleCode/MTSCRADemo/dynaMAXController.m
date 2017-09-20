//
//  dynaMAXController.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/22/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "dynaMAXController.h"

@interface dynaMAXController ()

@end

@implementation dynaMAXController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"DynaMAX";
    
    self.lib = [MTSCRA new];
    self.lib.delegate = self;
    
    [self.lib setDeviceType:MAGTEKDYNAMAX];
    
    //        [self.btnConnect setTitle:@"Scan" forState:UIControlStateNormal];
    [self.btnConnect removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnConnect addTarget:self action:@selector(scanForBLE) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.txtData.text = [NSString stringWithFormat:@"App Version: %@.%@ , SDK Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], self.lib.getSDKVersion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated
{
   // [self.lib closeDevice];
    
}
- (void)deviceNotPaired
{
    self.txtData.text = @"Error: Device not Paired.";
    
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

-(void) onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL)connected instance:(id)instance
{
    [super onDeviceConnectionDidChange:deviceType connected:connected instance:instance];
    
    
    
}

-(void)didSelectBLEReader:(CBPeripheral *)per
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.txtData.text = @"Connecting...";
        self.lib.delegate = self;
        [self.navigationController popViewControllerAnimated:YES];
        [self.lib setUUIDString:per.identifier.UUIDString];
        
        [self.lib openDevice];
    });
}
-(void)bleReaderStateUpdate:(MTSCRABLEState)state
{
    
    NSLog(@"BLE State: %d", state);
    
    if(state == UNSUPPORTED)
    {
        [[[UIAlertView alloc]initWithTitle:@"BLE Error" message:@"BLE is unsupported on this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

//
//  FirstViewController.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "iDynamoController.h"

@interface iDynamoController ()

@end

@implementation iDynamoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"iDynamo";
    
    //[self.btnConnect addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    
    self.lib = [MTSCRA new];
    self.lib.delegate = self;
    
    [self.lib setDeviceType:MAGTEKIDYNAMO];
    [self.lib setDeviceProtocolString:@"com.magtek.idynamo"];
    
    self.txtData.text = [NSString stringWithFormat:@"App Version: %@.%@ , SDK Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], self.lib.getSDKVersion];
    
    //[self.lib openDevice];
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self.lib closeDevice];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end

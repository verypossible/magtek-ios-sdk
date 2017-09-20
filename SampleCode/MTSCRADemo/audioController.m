//
//  SecondViewController.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "audioController.h"

@interface audioController ()

@end

@implementation audioController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Audio";
    self.lib = [MTSCRA new];
    self.lib.delegate = self;
    [self.lib setDeviceType:MAGTEKAUDIOREADER];
    
    self.txtData.text = [NSString stringWithFormat:@"App Version: %@.%@ , SDK Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], self.lib.getSDKVersion];
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
     [self.lib closeDevice];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

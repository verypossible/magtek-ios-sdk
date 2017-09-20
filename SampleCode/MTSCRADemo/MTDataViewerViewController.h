//
//  MTDataViewerViewController.h
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MTSCRA.h"
#import "HexUtil.h"
#import "NSObject+TLVParser.h"
@interface MTDataViewerViewController : UIViewController < UITextFieldDelegate, UIActionSheetDelegate,UISearchBarDelegate>

- (void)connect;

@property (nonatomic, strong) UIButton* btnConnect ;
@property (nonatomic, strong) UIButton* btnSendCommand ;
@property (atomic, strong) UITextView* txtData;
@property (nonatomic, strong) UITextField* txtCommand;
@property (nonatomic, strong) MTSCRA* lib;


- (NSString *)getHexString:(NSData *)data;
- (void) onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL)connected instance:(id)instance;
- (void)onDeviceResponse:(NSData *)data;
- (void)onDeviceError:(NSError *)error;
@end

//
//  eDynamoController.h
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/22/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "MTDataViewerViewController.h"
#import "BLEScannerList.h"
#import "optionController.h"
@interface eDynamoController : MTDataViewerViewController<MTSCRAEventDelegate, BLEScanListEvent, optionControllerEvent>
@property (nonatomic, strong) UIButton* btnStartEMV;
@property (nonatomic, strong) UIButton* btnGetStatus;

@end

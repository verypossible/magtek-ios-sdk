//
//  BLEScannerList.h
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/22/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTSCRA.h"

@protocol BLEScanListEvent <NSObject>
@optional
-(void)didSelectBLEReader:(MTDeviceInfo*)per;

@end

@interface BLEScannerList : UITableViewController<MTSCRAEventDelegate,UISearchBarDelegate>
{
    UISearchBar* searchBar;
}


- (id)initWithStyle:(UITableViewStyle)style lib:(MTSCRA*)lib;

@property (nonatomic, strong) MTSCRA* lib;
@property (nonatomic, strong) NSMutableArray* deviceList;
@property (nonatomic, weak) id <BLEScanListEvent> delegate;
@end

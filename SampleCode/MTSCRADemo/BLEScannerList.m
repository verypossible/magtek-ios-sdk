//
//  BLEScannerList.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/22/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "BLEScannerList.h"

@interface BLEScannerList ()

@end

@implementation BLEScannerList

- (id)initWithStyle:(UITableViewStyle)style lib:(MTSCRA*)lib
{
    if(self = [super initWithStyle:style])
    {
        _lib = lib;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableCell"];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    searchBar.delegate = self;
    
    self.tableView.tableHeaderView = searchBar;
    

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length > 0)
    {
        [self.lib stopScanningForPeripherals];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@", searchText.uppercaseString];
        _deviceList = [[self.lib getDiscoveredPeripherals] filteredArrayUsingPredicate:predicate].copy;
    }
    else
    {
        self.lib.delegate = self;
        [self.lib startScanningForPeripherals];
        _deviceList = [self.lib getDiscoveredPeripherals];
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if(_lib)
    {
        //[_lib openDevice];
        _lib.delegate = self;
        
        _deviceList = [NSMutableArray new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_lib startScanningForPeripherals];
        });
    }
}
-(void)bleReaderStateUpdated:(MTSCRABLEState)state
{
    
    
    if(state == UNSUPPORTED)
    {
        [[[UIAlertView alloc]initWithTitle:@"BLE Error" message:@"BLE is unsupported on this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        
    }
}
- (void)bleReaderDidDiscoverPeripheral
{
    _deviceList = [_lib getDiscoveredPeripherals];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _deviceList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [(CBPeripheral*)_deviceList[indexPath.row] name];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(didSelectBLEReader:)])
    {

        [_lib stopScanningForPeripherals];
        [[self delegate]didSelectBLEReader:_deviceList[indexPath.row]];
        
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
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

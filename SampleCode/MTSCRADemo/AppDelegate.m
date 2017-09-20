//
//  AppDelegate.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "AppDelegate.h"
#import "iDynamoController.h"
#import "audioController.h"
#import "dynaMAXController.h"
#import "eDynamoController.h"
@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor grayColor], NSForegroundColorAttributeName,
                                                       [UIFont systemFontOfSize: 13 ],
                                                       NSFontAttributeName,
                                                       nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        UIColorFromRGB(0xCC3333), NSForegroundColorAttributeName,
                                                       [UIFont systemFontOfSize: 13 ],
                                                       NSFontAttributeName,
                                                       nil] forState:UIControlStateSelected];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
     //[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(rgbValue)];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0xcc3333)];
    
    self.window.backgroundColor = [UIColor whiteColor];

    iDynamoController *idVc = [iDynamoController new];

    
    
    
    audioController *auVc = [audioController new];
    
    
    dynaMAXController *dyVC = [dynaMAXController new];
    
    eDynamoController *eVc = [eDynamoController new];
    
    
    UINavigationController *iNav = [[UINavigationController alloc] initWithRootViewController:idVc];
    iNav.navigationBar.translucent = NO;
    iNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"iDynamo" image:nil tag:0];
    iNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -16);
    
    
    UINavigationController *auNav = [[UINavigationController alloc] initWithRootViewController:auVc];
    auNav.navigationBar.translucent = NO;
    auNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Audio" image:nil tag:1];
    auNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -16);
    
    UINavigationController *dyNav = [[UINavigationController alloc] initWithRootViewController:dyVC];
    dyNav.navigationBar.translucent = NO;
    dyNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"DynaMAX" image:nil tag:2];
    dyNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -16);
    
    UINavigationController *evNav = [[UINavigationController alloc] initWithRootViewController:eVc];
    evNav.navigationBar.translucent = NO;
    evNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"eDynamo" image:nil tag:3];
    evNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -16);
    
    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers = @[iNav, auNav, dyNav, evNav ];
    tabBarController.tabBar.translucent = NO;
    

   // [tabBarController setViewControllers:@[idVc, auVc, dyVC, eVc]];
    
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

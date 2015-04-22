//
//  AppDelegate.m
//  Eleye
//
//  Created by Sheldon on 15/4/17.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "AppDelegate.h"
#import <ENSDK/ENSDK.h>
#import "ELaunchViewController.h"
#import "EAllNoteBooksViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSString *SANDBOX_HOST = ENSessionHostSandbox;
    
    NSString *CONSUMER_KEY = @"yousurm-4843";
    NSString *CONSUMER_SECRET = @"19601b04ea2a0f05";
    
    [ENSession setSharedSessionConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET optionalHost:SANDBOX_HOST];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([ENSession sharedSession].isAuthenticated) {
        EAllNoteBooksViewController *allNotebooksViewController = [storyboard instantiateViewControllerWithIdentifier:@"EAllNoteBooksViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:allNotebooksViewController];
        navController.navigationBarHidden = YES;
        self.window.rootViewController = navController;
    } else {
        UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ELaunchViewController"];
        self.window.rootViewController = rootViewController;
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL didHandle = [[ENSession sharedSession] handleOpenURL:url];
    
    return didHandle;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

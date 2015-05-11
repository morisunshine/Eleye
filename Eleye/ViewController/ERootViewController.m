//
//  ERootViewController.m
//  Eleye
//
//  Created by Sheldon on 15/5/11.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ERootViewController.h"
#import "EAllNoteBooksViewController.h"
#import "ELaunchViewController.h"
#import "EGuideViewController.h"

@interface ERootViewController ()

@end

@implementation ERootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController;
    
    NSString *host = [USER_DEFAULT objectForKey:HOSTNAME];
    NSString *SANDBOX_HOST;
#if DEBUG
    SANDBOX_HOST = ENSessionHostSandbox;
#else
    SANDBOX_HOST = nil;
#endif
    NSString *CONSUMER_KEY;
    NSString *CONSUMER_SECRET;
    
    if (host) {
        if ([host isEqualToString:EVERNOTEHOST]) {
            CONSUMER_KEY = EVERNOTECONSUMER_KEY;
            CONSUMER_SECRET = EVERNOTECONSUMER_SECRET;
        } else {
            CONSUMER_KEY = YINXIANGCONSUMER_KEY;
            CONSUMER_SECRET = YINXIANGCONSUMER_SECRET;
        }
        
        [ENSession setSharedSessionConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET optionalHost:SANDBOX_HOST];
        
        if ([ENSession sharedSession].isAuthenticated) {
            EAllNoteBooksViewController *allNotebooksViewController = [storyboard instantiateViewControllerWithIdentifier:@"EAllNoteBooksViewController"];
            allNotebooksViewController.showAllNotes = YES;
            viewController = allNotebooksViewController;
        } else {
            ELaunchViewController *launchViewController = [storyboard instantiateViewControllerWithIdentifier:@"ELaunchViewController"];
            launchViewController.showNoAnimation = YES;
            viewController = launchViewController;
        }
    } else {
        ELaunchViewController *launchViewController = [storyboard instantiateViewControllerWithIdentifier:@"ELaunchViewController"];
        launchViewController.showNoAnimation = YES;
        viewController = launchViewController;
    }
    
    if ([USER_DEFAULT objectForKey:SHOWGUIDE] == nil) {
        EGuideViewController *guidViewController = [storyboard instantiateViewControllerWithIdentifier:@"EGuideViewController"];
        [self.navigationController presentViewController:guidViewController animated:NO completion:nil];
    }
    
    [self.navigationController pushViewController:viewController animated:NO];
    // Do any additional setup after loading the view.
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

@end

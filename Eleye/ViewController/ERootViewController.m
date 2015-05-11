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
    
    NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    NSString *SANDBOX_HOST;
#if DEBUG
    SANDBOX_HOST = ENSessionHostSandbox;
#else
    SANDBOX_HOST = nil;
#endif
    NSString *CONSUMER_KEY;
    NSString *CONSUMER_SECRET;
    
    if (host) {
        if ([host isEqualToString:@"evernote"]) {
            CONSUMER_KEY = @"yousurm";
            CONSUMER_SECRET = @"cb61b2f2bbbcb741";
        } else {
            CONSUMER_KEY = @"yousurm-4843";
            CONSUMER_SECRET = @"19601b04ea2a0f05";
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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SHOWGUIDE] == nil) {
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

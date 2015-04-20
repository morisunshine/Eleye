//
//  ViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/17.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ELaunchViewController.h"
#import <ENSession.h>

@interface ELaunchViewController ()

@end

@implementation ELaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)yxUserBtnTapped:(id)sender {
    ENSession *session = [ENSession sharedSession];
    [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError *authenticateError) {
        if (authenticateError) {
            NSLog(@"登录失败");
        } else {
            NSLog(@"授权成功");
        }
    }];
}


@end

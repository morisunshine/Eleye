//
//  ENoteViewController.m
//  Eleye
//
//  Created by sheldon on 15/5/7.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteViewController.h"

@interface ENoteViewController ()

@end

@implementation ENoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *htmlString = [EUtility contentFromLocalPathWithGuid:self.guid];
    
    // Set the HTML contents of the editor
    [self setHTML:htmlString];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

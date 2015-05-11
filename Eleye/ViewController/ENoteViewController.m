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
    
    [self configureUI];
    
    // Set the HTML contents of the editor
    [self setHTML:htmlString];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Mathods -

- (void)configureUI
{
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGR:)];
    [self.editorView addGestureRecognizer:panGR];
}

#pragma mark - Actions -

- (IBAction)panGR:(UIPanGestureRecognizer *)sender
{
    CGPoint vel = [sender velocityInView:self.view];
    if (vel.x > 50) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

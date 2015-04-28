//
//  ViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/17.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ELaunchViewController.h"
#import "EAllNoteBooksViewController.h"
#import <ENSession.h>

@interface ELaunchViewController ()

@property (weak, nonatomic) IBOutlet UIButton *evernoteBtn;
@property (weak, nonatomic) IBOutlet UIButton *yingxiangBtn;

@end

@implementation ELaunchViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self configureUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureUI
{
    [EUtility addlineOnView:self.evernoteBtn position:EViewPositionBottom];
}

- (IBAction)evernoteUserBtnTapped:(id)sender 
{
    [self authorization];
}

- (IBAction)yxUserBtnTapped:(id)sender 
{
    [self authorization];
}

#pragma mark - Private Methods -

- (void)authorization
{
    ENSession *session = [ENSession sharedSession];
    [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError *authenticateError) {
        if (authenticateError) {
            NSLog(@"登录失败");
        } else {
            NSLog(@"授权成功");
            [self authorizationWithSuccess];
        }
    }];
}

- (void)authorizationWithSuccess
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EAllNoteBooksViewController *allNoteBooksViewController = [story instantiateViewControllerWithIdentifier:@"EAllNoteBooksViewController"];
    allNoteBooksViewController.showAllNotes = YES;
    [self.navigationController pushViewController:allNoteBooksViewController animated:YES];
    NSMutableArray *mutViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [mutViewControllers removeObjectAtIndex:1];
    self.navigationController.viewControllers = mutViewControllers;
}

@end

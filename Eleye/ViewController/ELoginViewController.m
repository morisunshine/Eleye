//
//  ViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/17.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ELoginViewController.h"
#import "EAllNoteBooksViewController.h"
#import <ENSession.h>
#import "ELoginView.h"

@interface ELoginViewController ()

@property (nonatomic, retain) ELoginView *loginView;

@end

@implementation ELoginViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self configureUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.showNoAnimation == NO) {
        self.loginView.evernoteBtn.alpha = 0;
        self.loginView.yinxiangBtn.alpha = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.showNoAnimation == NO) {
        [UIView animateWithDuration:1 animations:^{
            self.loginView.evernoteBtn.alpha = 1;
            self.loginView.yinxiangBtn.alpha = 1;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters -

- (ELoginView *)loginView
{
    if (!_loginView) {
        _loginView = [[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil][1];
        _loginView.frame = [UIScreen mainScreen].bounds;
        _loginView.evernoteBtn.alpha = 1;
        _loginView.yinxiangBtn.alpha = 1;
        [_loginView.evernoteBtn addTarget:self action:@selector(evernoteUserBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView.yinxiangBtn addTarget:self action:@selector(yxUserBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loginView;
}

#pragma mark - Actions -

- (IBAction)evernoteUserBtnTapped:(id)sender
{
    [self authorizationWithEvernote:YES];
}

- (IBAction)yxUserBtnTapped:(id)sender
{
    [self authorizationWithEvernote:NO];
}

#pragma mark - Private Methods -

- (void)configureUI
{
    [self.view addSubview:self.loginView];
}

- (void)authorizationWithEvernote:(BOOL)evernote
{
    NSString *SANDBOX_HOST = ENSessionHostSandbox;//TODO 线上后要改为nil
    NSString *CONSUMER_KEY;
    NSString *CONSUMER_SECRET;
    
    if (evernote) {
        CONSUMER_KEY = EVERNOTECONSUMER_KEY;
        CONSUMER_SECRET = EVERNOTECONSUMER_SECRET;
    } else {
        CONSUMER_KEY = YINXIANGCONSUMER_KEY;
        CONSUMER_SECRET = YINXIANGCONSUMER_SECRET;
    }
    
    [ENSession setSharedSessionConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET optionalHost:SANDBOX_HOST];
    
    ENSession *session = [ENSession sharedSession];
    [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError *authenticateError) {
        if (authenticateError) {
            NSLog(@"登录失败:%@", authenticateError);
            [EUtility showAutoHintTips:LOCALSTRING(@"Login failure")];
        } else {
            NSLog(@"授权成功");
            [EUtility showAutoHintTips:LOCALSTRING(@"Login success")];
            NSString *hostString;
            if (evernote) {
                hostString = EVERNOTEHOST;
            } else {
                hostString = YINXIANGHOST;
            }
            [USER_DEFAULT setObject:hostString forKey:HOSTNAME];
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

//
//  EGuideViewController.m
//  Eleye
//
//  Created by Sheldon on 15/5/6.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EGuideViewController.h"
#import "ELoginView.h"

@interface EGuideViewController () <UIScrollViewDelegate>
{
    ELoginView *lastView_;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation EGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureScrollView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureScrollView
{
    self.scrollView.contentSize = CGSizeMake(APP_SCREEN_WIDTH * 4, 0);
    for (NSInteger i = 0; i < 3; i++) {
        NSString *imageName = [NSString stringWithFormat:@"guid0%@", @(i + 1)];
        UIImageView *guideImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        guideImageView.frame = self.scrollView.bounds;
        guideImageView.left = i * APP_SCREEN_WIDTH;
        [self.scrollView addSubview:guideImageView];
    }
    
    lastView_ = [[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil][1];
    lastView_.left = APP_SCREEN_WIDTH * 3;
    [self.scrollView addSubview:lastView_];
}

#pragma mark - ScrollView Delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage = scrollView.contentOffset.x / APP_SCREEN_WIDTH;
    if (currentPage == 3) {
        [USER_DEFAULT setObject:@(YES) forKey:SHOWGUIDE];
        [UIView animateWithDuration:1 animations:^{
            lastView_.evernoteBtn.alpha = 1;
            lastView_.yinxiangBtn.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    }
}

@end

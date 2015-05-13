//
//  MLNavigationController.h
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MHTabBarControllerViewControllerPushNotification;
extern NSString *const MHTabBarControllerViewControllerPopNotification;

@interface MHNavigationController : UINavigationController <UIGestureRecognizerDelegate>

// Enable the drag to back interaction, Defalt is YES.
@property (nonatomic,assign) BOOL canDragBack;

- (void)customPushViewController:(UIViewController *)viewController fromViewController:(UIViewController *)fromViewController;

@end

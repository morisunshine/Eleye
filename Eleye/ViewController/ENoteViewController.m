//
//  ENoteViewController.m
//  Eleye
//
//  Created by sheldon on 15/5/7.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteViewController.h"
#import <objc/runtime.h>

@interface ENoteViewController ()
{
    NSString *htmlString_;
}

@end

@implementation ENoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    htmlString_ = [EUtility contentFromLocalPathWithGuid:self.guid];
    
    if (htmlString_) {
        NSDictionary *updateNotes = [USER_DEFAULT objectForKey:@"updateNotes"];
        if ([updateNotes objectForKey:self.guid]) {
            [self fetchNoteContent];
        } else {
            //不需要更新
            [self configUI];
        }
    } else {
        [self fetchNoteContent];
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self replaceUIWebBrowserView:self.editorView];
    
    NSMutableArray *extraItems = [[NSMutableArray alloc] init];
    UIMenuItem *highlightItem = [[UIMenuItem alloc] initWithTitle:@"Highlight"
                                                      action:@selector(highlightBtnTapped:)];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyBtnTapped:)];
    [extraItems addObject:highlightItem];
    [extraItems addObject:copyItem];
    [UIMenuController sharedMenuController].menuItems = extraItems;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self replaceUIWebBrowserView:self.editorView];
    
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -

- (void)configUI
{
    [self setHTML:htmlString_];
    [self changeTopTitle:self.noteTitle];
}

- (void)fetchNoteContent
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *enote) {
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:enote];
        htmlString_ = [resultNote.content enmlWithNote:resultNote];
        [self configUI];
        [[EUtility sharedEUtility] saveContentToFileWithContent:htmlString_ guid:self.guid];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记内容错误%@", error);
        }
    }];
}

#pragma mark - Private Methods -

- (void)replaceUIWebBrowserView: (UIView *)view
{
    //Iterate through subviews recursively looking for UIWebBrowserView
    for (UIView *sub in view.subviews) {
        [self replaceUIWebBrowserView:sub];
        if ([NSStringFromClass([sub class]) isEqualToString:@"UIWebBrowserView"]) {
            
            Class class = sub.class;
            
            SEL originalSelector = @selector(canPerformAction:withSender:);
            SEL swizzledSelector = @selector(mightPerformAction:withSender:);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);            
            //add the method mightPerformAction:withSender: to UIWebBrowserView
            
            //replace canPerformAction:withSender: with mightPerformAction:withSender:
            
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

- (BOOL)mightPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

#pragma mark - Actions -

- (IBAction)highlightBtnTapped:(id)sender
{
    [self addHighlight];
}

- (IBAction)copyBtnTapped:(id)sender
{
    NSString *selectedText = [self.editorView stringByEvaluatingJavaScriptFromString: @"window.getSelection().toString()"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:selectedText];
}

@end

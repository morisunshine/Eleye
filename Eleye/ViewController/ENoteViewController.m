//
//  ENoteViewController.m
//  Eleye
//
//  Created by sheldon on 15/5/7.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteViewController.h"
#import <objc/runtime.h>
#import "ENoteDAO.h"

@interface ENoteViewController ()
{
    NSString *htmlString_;
    EDAMNote *enote_;
}

@end

@implementation ENoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    htmlString_ = [EUtility contentFromLocalPathWithGuid:self.guid];
    
    [self changeTopTitle:self.noteTitle];
    
    //TODO 测试
    [self fetchNoteContent];
    enote_ = [[ENoteDAO sharedENoteDAO] noteWithGuid:self.guid];
    //TODO
    
    if (htmlString_) {
        NSDictionary *updateNotes = [USER_DEFAULT objectForKey:@"updateNotes"];
        if ([updateNotes objectForKey:self.guid]) {
            [self fetchNoteContent];
        } else {
            //不需要更新
            [self setupData];
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
    
    [self changeMenuItemsWithShowHighLight:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self replaceUIWebBrowserView:self.editorView];
    
    [self updateNote];
    
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -

- (void)setupData
{
    [self setHTML:htmlString_];
    [self changeTopTitle:self.noteTitle];
}

- (void)fetchNoteContent
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *enote) {
        enote_ = enote;
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:enote];
        [self downloadImagesWithResources:resultNote.resources];
        htmlString_ = [resultNote.content enmlWithNote:resultNote];
        [self setupData];
        [[EUtility sharedEUtility] saveContentToFileWithContent:htmlString_ guid:self.guid];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记内容错误%@", error);
        }
    }];
}

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

- (void)changeMenuItemsWithShowHighLight:(BOOL)showHighlight
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    UIMenuItem *actionItem = [[UIMenuItem alloc] initWithTitle:@"Cancel"
                                                           action:@selector(highlightBtnTapped:)];
    if (showHighlight) {
        actionItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlightBtnTapped:)];
    } else {
        actionItem = [[UIMenuItem alloc] initWithTitle:@"Cancel" action:@selector(cancelBtnTapped:)];
    }
    
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyBtnTapped:)];
    [menuItems addObject:actionItem];
    [menuItems addObject:copyItem];
    [UIMenuController sharedMenuController].menuItems = menuItems;
}

- (void)downloadImagesWithResources:(NSArray *)resources
{
    //        //
    //        NSMutableArray * edamResources = [NSMutableArray arrayWithCapacity:enote.resources.count];
    //        for (ENResource * resource in resultNote.resources) {
    //            EDAMResource * edamResource = [resource EDAMResource];
    //            if (edamResource.attributes.sourceURL == nil) {
    //                NSString * dataHash = [resource.dataHash enlowercaseHexDigits];
    //                NSString * extension = [ENMIMEUtils fileExtensionForMIMEType:resource.mimeType];
    //                NSString * fakeUrl = [NSString stringWithFormat:@"http://example.com/%@.%@", dataHash, extension];
    //                edamResource.attributes.sourceURL = fakeUrl;
    //            }
    //            [edamResources addObject:edamResource];
    //        }

}

- (void)updateNote
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    
    enote_.content = htmlString_;
    
    [client updateNote:enote_ success:^(EDAMNote *note) {
        NSLog(@"更新笔记成功 %@", note.content);
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"更新笔记失败%@", error);
        }
    }];
}

#pragma mark - Actions -

- (IBAction)highlightBtnTapped:(id)sender
{
    [self addHighlight];
}

- (IBAction)cancelBtnTapped:(id)sender
{
    
}

- (IBAction)copyBtnTapped:(id)sender
{
    NSString *selectedText = [self.editorView stringByEvaluatingJavaScriptFromString: @"window.getSelection().toString()"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:selectedText];
}

@end

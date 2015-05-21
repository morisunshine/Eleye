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
#import <ENMIMEUtils.h>
#import <ENMLUtility.h>
#import <NSData+EvernoteSDK.h>
#import "EResourceDO.h"
#import "EResourceDAO.h"

@interface ENoteViewController ()
{
    NSString *htmlString_;
    EDAMNote *enote_;
    BOOL hasUpdateNote_;
}

@end

@implementation ENoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    htmlString_ = [EUtility noteHtmlFromLocalPathWithGuid:self.guid];
    
    [self changeTopTitle:self.noteTitle];
    
    enote_ = [[ENoteDAO sharedENoteDAO] noteWithGuid:self.guid];
    
    if (htmlString_) {
        if ([EUtility valueWithKey:self.guid fileName:REMOTEUPDATEDTITLE]) {
            [self fetchNoteContent];
        } else {
            //不需要更新
            [self setupDataWithResources:nil];
        }
    } else {
        [self fetchNoteContent];
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[Mixpanel sharedInstance] timeEvent:@"单篇文章"];
    
    [self replaceUIWebBrowserView:self.editorView];
    
    [self changeMenuItemsWithShowHighLight:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[Mixpanel sharedInstance] track:@"单篇文章"];
    
    [self replaceUIWebBrowserView:self.editorView];
    
    if (hasUpdateNote_) {
        [self updateNote];
    }
    
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -

- (void)setupDataWithResources:(NSArray *)resources
{
    NSMutableArray *newResources;
    if (resources) {
        NSMutableArray *mutResources = [[NSMutableArray alloc] init];
        for (ENResource *resource in resources) {
            EResourceDO *resourceDO = [[EResourceDO alloc] init];
            resourceDO.noteGuid = self.guid;
            resourceDO.resource = resource;
            [mutResources addObject:resourceDO];
        }
        newResources = mutResources;
        [[EResourceDAO sharedEResourceDAO] saveItems:mutResources];
    } else {
        resources = [[EResourceDAO sharedEResourceDAO] resourcesWithNoteGuid:self.guid];
        newResources = [NSMutableArray arrayWithArray:resources];
    }
    NSMutableArray * edamResources = [NSMutableArray arrayWithCapacity:newResources.count];
    for (EResourceDO * resourceDO in newResources) {
        ENResource *resource = resourceDO.resource;
        EDAMResource * edamResource = [resource EDAMResource];
        if (!edamResource.attributes.sourceURL) {
            NSString * dataHash = [resource.dataHash enlowercaseHexDigits];
            NSString * extension = [ENMIMEUtils fileExtensionForMIMEType:resource.mimeType];
            NSString * fakeUrl = [NSString stringWithFormat:@"http://example.com/%@.%@", dataHash, extension];
            edamResource.attributes.sourceURL = fakeUrl;
        }
        [edamResources addObject:edamResource];
    }
    
    if (0 < resources.count) {
        ENMLUtility *utility = [[ENMLUtility alloc] init];
        [utility convertENMLToHTML:htmlString_ withInlinedResources:edamResources completionBlock:^(NSString *html, NSError *error) {
            [self setHTML:html];
        }];
    } else {
        [self setHTML:htmlString_];
    }

    [self changeTopTitle:self.noteTitle];
}

- (void)fetchNoteContent
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *enote) {
        enote_ = enote;
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:enote];
        [EUtility saveDataBaseResources:resultNote.resources withNoteGuid:self.guid];
        htmlString_ = [resultNote.content enmlWithNote:resultNote];
        [self setupDataWithResources:resultNote.resources];
        [[EUtility sharedEUtility] saveContentToFileWithContent:htmlString_ guid:self.guid];
        [EUtility removeValueWithKey:self.guid fileName:REMOTEUPDATEDTITLE];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记内容错误%@", error);
        }
    }];
}

//Thanks Shayan RC http://stackoverflow.com/a/25263688/2194236
- (void)replaceUIWebBrowserView: (UIView *)view
{
    for (UIView *sub in view.subviews) {
        [self replaceUIWebBrowserView:sub];
        if ([NSStringFromClass([sub class]) isEqualToString:@"UIWebBrowserView"]) {
            
            Class class = sub.class;
            
            SEL originalSelector = @selector(canPerformAction:withSender:);
            SEL swizzledSelector = @selector(mightPerformAction:withSender:);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);            
            
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
    UIMenuItem *actionItem;
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

- (void)updateNote
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    
    enote_.content = htmlString_;
    
    [client updateNote:enote_ success:^(EDAMNote *note) {
        NSLog(@"更新笔记成功 %@", note.title);
        
        [EUtility setSafeValue:note.updated key:self.guid fileName:LOCALUPDATEFILE];
        
        enote_.updated = note.updated;
        [[ENoteDAO sharedENoteDAO] saveBaseDO:enote_];
        [[EUtility sharedEUtility] saveContentToFileWithContent:htmlString_ guid:self.guid];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"更新笔记失败%@", error);
        }
    }];
}

- (void)clearSelectionRange
{
    self.editorView.userInteractionEnabled = NO;
    self.editorView.userInteractionEnabled = YES;
}

#pragma mark - Actions -

- (IBAction)highlightBtnTapped:(id)sender
{
    [[Mixpanel sharedInstance] track:@"高亮文字"];
    //TODO 根据高亮的文字变化
    hasUpdateNote_ = YES;
    [self addHighlight];
    
    [self clearSelectionRange];
}

- (IBAction)cancelBtnTapped:(id)sender
{
    [[Mixpanel sharedInstance] track:@"取消高亮文字"];
    //TODO 根据高亮的文字变化
    hasUpdateNote_ = NO;
    
    [self cancelHighlight];
    
    [self clearSelectionRange];
}

- (IBAction)copyBtnTapped:(id)sender
{
    NSString *selectedText = [self.editorView stringByEvaluatingJavaScriptFromString: @"window.getSelection().toString()"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:selectedText];
    
    [self clearSelectionRange];
}

#pragma mark - Webview Delegate  -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"web request");
    NSLog(@"%@", urlString);
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[Mixpanel sharedInstance] track:@"点击外部链接"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        return NO;
    } else if ([urlString rangeOfString:@"callback://"].location != NSNotFound) {
        NSString *result = [self.editorView stringByEvaluatingJavaScriptFromString:@"EReader.isHilite()"];
        NSLog(@"选中是否高亮，%@", result);
        BOOL isHighlight = NO;
        if ([result isEqualToString:@"false"]) {
            isHighlight = YES;
        }
        [self changeMenuItemsWithShowHighLight:isHighlight];
    }
    
    return YES;
}

@end

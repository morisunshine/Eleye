//
//  ENoteViewController.m
//  Eleye
//
//  Created by sheldon on 15/5/7.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteViewController.h"

@interface ENoteViewController ()
{
    NSString *htmlString_;
}

@end

@implementation ENoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    htmlString_ = [EUtility contentFromLocalPathWithGuid:self.guid];
    // Set the HTML contents of the editor
    [self setHTML:htmlString_];
    [self setTopTitle:self.noteTitle];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSMutableArray *extraItems = [[NSMutableArray alloc] init];
    UIMenuItem *boldItem = [[UIMenuItem alloc] initWithTitle:@"Bold"
                                                      action:@selector(highlightBtnTapped:)];
    [extraItems addObject:boldItem];
    [UIMenuController sharedMenuController].menuItems = extraItems;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.editorView.superview != nil) {
        if (action == @selector(highlightBtnTapped:)) {
            return YES;
        }
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -

- (void)fetchNoteContent
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *enote) {
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:enote];
        htmlString_ = [resultNote.content enmlWithNote:resultNote];
        [self setHTML:htmlString_];
        [EUtility saveContentToFileWithContent:htmlString_ guid:self.guid];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记内容错误%@", error);
        }
    }];
}

#pragma mark - Actions -

- (IBAction)highlightBtnTapped:(UIButton *)sender
{
    
}

@end

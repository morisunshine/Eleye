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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

@end

//
//  ENoteDetailViewController.m
//  Eleye
//
//  Created by sheldon on 15/4/24.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteDetailViewController.h"

@interface ENoteDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation ENoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.noteTitle;
    
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:note];
        NSString *contentString = [resultNote.content enmlWithNote:resultNote];
        [EUtility saveContentToFileWithContent:contentString guid:note.guid];
        NSLog(@"%@", note.content);
    } failure:^(NSError *error) {
        
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

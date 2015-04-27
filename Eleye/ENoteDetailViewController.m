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
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation ENoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    [self readContentFromLocal];
    
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
        
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:note];
        NSString *contentString = [resultNote.content enmlWithNote:resultNote];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[contentString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        self.contentTextView.text = attributedString.string;
        
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记失败");
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -

- (void)configureUI
{
    self.titleLabel.text = self.noteTitle;
    [EUtility addlineOnView:self.titleView position:EViewPositionBottom];
}

- (void)readContentFromLocal
{
    NSAttributedString *attributedString = [EUtility stringFromLocalPathWithGuid:self.guid];
    self.contentTextView.text = attributedString.string;
    
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         NSString *subString = [attributedString.string substringWithRange:range];
         NSLog(@"%@", attributes);
         NSLog(@"SUBSTRING:%@", subString);
//         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
//         [mutableAttributes setObject:[NSNumber numberWithInt:1] forKey:@"NSUnderline"];
//         [attributedString setAttributes:mutableAttributes range:range];
         
     }];
}

@end

//
//  ENoteDetailViewController.m
//  Eleye
//
//  Created by sheldon on 15/4/24.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteDetailViewController.h"

@interface ENoteDetailViewController () <UITextViewDelegate>

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([self.contentTextView isFirstResponder] && [touch view] != self.contentTextView) {
        [self.contentTextView resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - TextView Delegate -

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"Selection changed");
    
    NSLog(@"loc = %ld", textView.selectedRange.location);
    NSLog(@"len = %ld", textView.selectedRange.length);
}

#pragma mark - Private Methods -

- (void)configureUI
{
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlightBtnTapped:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:menuItem]];
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



#pragma mark - Actions -

- (IBAction)highlightBtnTapped:(UIButton *)sender
{
    NSLog(@"highlight");
    
    NSRange selectedRange = self.contentTextView.selectedRange;
    
    NSDictionary *currentAttributesDict = [self.contentTextView.textStorage attributesAtIndex:selectedRange.location
                                                                    effectiveRange:nil];
    
    if ([currentAttributesDict objectForKey:NSForegroundColorAttributeName] == nil ||
        [currentAttributesDict objectForKey:NSForegroundColorAttributeName] != [UIColor redColor]) {
        
        UIFont *font = [UIFont systemFontOfSize:16];
        NSDictionary *dict = @{NSForegroundColorAttributeName: RGBCOLOR(158, 87, 48), NSFontAttributeName: font};
        [self.contentTextView.textStorage beginEditing];
        [self.contentTextView.textStorage setAttributes:dict range:selectedRange];
        [self.contentTextView.textStorage endEditing];
    }
}

@end

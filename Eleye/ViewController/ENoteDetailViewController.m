//
//  ENoteDetailViewController.m
//  Eleye
//
//  Created by sheldon on 15/4/24.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteDetailViewController.h"
#import "EMenuView.h"
#import "ETextView.h"

@interface ENoteDetailViewController () <UITextViewDelegate>
{
    NSMutableAttributedString *attributedText_;
}

@property (nonatomic, retain) EMenuView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet ETextView *contentTextView;

@end

@implementation ENoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self readContentFromLocal];
    [self fetchNoteDetail];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters -

- (EMenuView *)menuView
{
    if (!_menuView) {
        _menuView = [[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil][1];
        _menuView.hidden = YES;
        __weak ENoteDetailViewController *weakSelf = self;
        _menuView.highlightBtnTappedHandler = ^(BOOL isHighlight) {
            [weakSelf highlightTextViewWithHighlight:isHighlight];
        };
        _menuView.copyBtnTappedHandler = ^() {
            [weakSelf cBtnTapped];
        };
    }
    
    return _menuView;
}

#pragma mark - TextView Delegate -

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self updateMenuView];
}

#pragma mark - Private Methods -

- (void)fetchNoteDetail
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:self.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
        
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:note];
        NSString *contentString = [resultNote.content enmlWithNote:resultNote];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithData:[contentString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        attributedText_ = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        self.contentTextView.text = attributedText.string;
        
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记失败");
        }
    }];
}

- (void)updateMenuView
{
    NSRange selectedRange = self.contentTextView.selectedRange;
    if (!selectedRange.length) {
        self.menuView.hidden = YES;
        return;
    }   
    
    // Find last rect of selection
    NSRange glyphRange = [self.contentTextView.layoutManager glyphRangeForCharacterRange:selectedRange actualCharacterRange:NULL];
    __block CGRect lastRect;
    [self.contentTextView.layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:glyphRange inTextContainer:self.contentTextView.textContainer usingBlock:^(CGRect rect, BOOL *stop) {
        lastRect = rect;
        *stop = YES;
    }];
    
    
    // Position clippy at bottom-right of selection
    CGPoint clippyCenter;
    clippyCenter.x = CGRectGetMidX(lastRect) + self.contentTextView.textContainerInset.left;
    clippyCenter.y = CGRectGetMinY(lastRect) + self.contentTextView.textContainerInset.top;
    clippyCenter = [self.contentTextView convertPoint:clippyCenter toView:self.view];
    clippyCenter.y -= self.menuView.height * 2;
    
    self.menuView.hidden = NO;
    self.menuView.center = clippyCenter;
}

- (void)configureUI
{
    self.titleLabel.text = self.noteTitle;
    [EUtility addlineOnView:self.titleView position:EViewPositionBottom];
    [self.contentTextView addSubview:self.titleView];
    [self.contentTextView addSubview:self.menuView];
    self.contentTextView.tintColor = RGBCOLOR(158, 87, 48);
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(46, 17, 0, 17);
}

- (void)readContentFromLocal
{
    attributedText_ = [[NSMutableAttributedString alloc] initWithAttributedString:[EUtility stringFromLocalPathWithGuid:self.guid]];
    self.contentTextView.text = attributedText_.string;
}

#pragma mark - Actions -

- (void)cBtnTapped
{
    NSString *selectedText = [self.contentTextView.text substringWithRange:self.contentTextView.selectedRange];
    [UIPasteboard generalPasteboard].string = selectedText;
}

- (void)highlightTextViewWithHighlight:(BOOL)highlight
{
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
    
    [attributedText_ enumerateAttributesInRange:selectedRange options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         NSString *subString = [attributedText_.string substringWithRange:range];
         NSLog(@"%@", attributes);
         NSLog(@"SUBSTRING:%@", subString);
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         [mutableAttributes setObject:RGBCOLOR(158, 87, 48) forKey:NSBackgroundColorDocumentAttribute];
         [attributedText_ setAttributes:mutableAttributes range:range];
     }];
}

@end

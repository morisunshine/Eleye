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
#import <TFHpple.h>

@interface ENoteDetailViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableDictionary *mutHeadStyleDics_;
    NSMutableArray *highlightRanges_;
    NSMutableAttributedString *attributedText_;
    NSMutableAttributedString *sourceAttributedText_;
}

@property (nonatomic, retain) EMenuView *menuView;
@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet ETextView *contentTextView;

@end

@implementation ENoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self readContentFromLocal];
    if (!attributedText_) {
        [self fetchNoteDetail];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters -

- (EMenuView *)menuView
{
    if (!_menuView) {
        _menuView = [[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:self options:nil][0];
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

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 46)];
        [_titleView addSubview:self.titleLabel];
        [EUtility addlineOnView:_titleView position:EViewPositionBottom];
    }
    
    return _titleView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, APP_SCREEN_WIDTH - 34, 46)];
        _titleLabel.textColor = RGBCOLOR(199, 199, 199);
        _titleLabel.font = FONT(15);
    }
    
    return _titleLabel;
}

#pragma mark - TextView Delegate -

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"selected:%@, %@", @(textView.selectedRange.location), @(textView.selectedRange.length));
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
        [self customStyleWithContent];
        
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记失败");
        }
    }];
}

- (void)updateMenuView
{
    NSRange selectedRange = self.contentTextView.selectedRange;
    if (selectedRange.length == 0) {
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
    highlightRanges_ = [[NSMutableArray alloc] init];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGR:)];
    [self.contentTextView addGestureRecognizer:tapGR];
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGR:)];
    [self.view addGestureRecognizer:panGR];
    self.titleLabel.text = self.noteTitle;
    self.titleView.top = self.contentTextView.top;
    self.titleView.left = self.contentTextView.left;
    [self.contentTextView addSubview:self.titleView];
    [self.contentTextView addSubview:self.menuView];
    self.contentTextView.tintColor = RGBCOLOR(158, 87, 48);
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(46, 17, 0, 17);
}

- (void)readContentFromLocal
{
    mutHeadStyleDics_ = [[NSMutableDictionary alloc] init];
    NSString *htmlString = [EUtility contentFromLocalPathWithGuid:self.guid];
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray *headTags = @[@"title", @"h1", @"h2", @"h3", @"h4", @"h5", @"h6"];
    
    for (NSString *tag in headTags) {
        NSString *xPath = [NSString stringWithFormat:@"//%@", tag];
        NSArray *elements = [doc searchWithXPathQuery:xPath];
        for (TFHppleElement *element in elements) {
            if (element.text) {
                [mutHeadStyleDics_ setObject:tag forKey:element.text];
            }
        }
    }
    
    attributedText_ = [[NSMutableAttributedString alloc] initWithAttributedString:[EUtility stringFromLocalPathWithGuid:self.guid]];
    sourceAttributedText_ = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText_];
    [self customStyleWithContent];
}

- (void)customStyleWithContent
{
    [attributedText_ enumerateAttributesInRange:NSMakeRange(0, attributedText_.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSLog(@"attrs:%@ range:%@, %@, text:%@", attrs, @(range.location), @(range.length), [attributedText_.string substringWithRange:range]);
        UIFont *font;
        NSString *subString = [attributedText_.string substringWithRange:range];
        subString = [subString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *tag = [mutHeadStyleDics_ objectForKey:subString];
        if (tag) {
            if ([tag isEqualToString:@"title"]) {
                font = FONT(20);
            } else if ([tag isEqualToString:@"h1"]) {
                font = FONT(20);
            } else if ([tag isEqualToString:@"h2"]) {
                font = FONT(16);
            } else if ([tag isEqualToString:@"h3"]) {
                font = FONT(15);
            } else if ([tag isEqualToString:@"h4"]) {
                font = FONT(14);
            } else if ([tag isEqualToString:@"h5"]) {
                font = FONT(14);
            } else if ([tag isEqualToString:@"h6"]) {
                font = FONT(14);
            }
        } else {
            font = FONT(14);
        }
        NSParagraphStyle *paragraphStyle = [attrs objectForKey:NSParagraphStyleAttributeName];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{NSBackgroundColorAttributeName: [UIColor whiteColor],
                                                                                   NSFontAttributeName: font,
                                                                                   NSParagraphStyleAttributeName: paragraphStyle,
                                                                                   NSForegroundColorAttributeName: RGBCOLOR(75, 75, 75)}];
        if ([attrs objectForKey:NSLinkAttributeName]) {
            [dic setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
            [dic setObject:RGBCOLOR(168, 87, 48) forKey:NSForegroundColorAttributeName];
            [dic setObject:[attrs objectForKey:NSLinkAttributeName] forKey:NSLinkAttributeName];
        } else {
            [dic setObject:RGBCOLOR(75, 75, 75) forKey:NSForegroundColorAttributeName];
        }
        [attributedText_ setAttributes:dic range:range];
    }];
    
    self.contentTextView.attributedText = attributedText_;
}

#pragma mark - Actions -

- (IBAction)panGR:(UIPanGestureRecognizer *)sender
{
    CGPoint vel = [sender velocityInView:self.view];
    if (vel.x > 50) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)tapGR:(UITapGestureRecognizer *)sender
{
    self.contentTextView.selectedRange = NSMakeRange(0, 0);
}

- (void)cBtnTapped
{
    NSString *selectedText = [self.contentTextView.text substringWithRange:self.contentTextView.selectedRange];
    [UIPasteboard generalPasteboard].string = selectedText;
}

- (void)highlightTextViewWithHighlight:(BOOL)highlight
{
    NSRange selectedRange = self.contentTextView.selectedRange;
    [attributedText_ enumerateAttributesInRange:selectedRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSMutableDictionary *mutAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        if (highlight) {
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRange.location inSection:selectedRange.length];
            [highlightRanges_ addObject:selectedIndexPath];
            [mutAttrs setObject:RGBACOLOR(168, 87, 48, 0.3) forKey:NSBackgroundColorAttributeName];
        } else {
            [mutAttrs setObject:[UIColor whiteColor] forKey:NSBackgroundColorAttributeName];
        }
        [attributedText_ setAttributes:mutAttrs range:range];
    }];
    
    [sourceAttributedText_ enumerateAttributesInRange:selectedRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSMutableDictionary *mutAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRange.location inSection:selectedRange.length];
        [highlightRanges_ addObject:selectedIndexPath];
        [mutAttrs setObject:RGBACOLOR(168, 87, 48, 0.3) forKey:NSBackgroundColorAttributeName];
        [sourceAttributedText_ setAttributes:mutAttrs range:range];
    }];
    
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [sourceAttributedText_ dataFromRange:NSMakeRange(0, sourceAttributedText_.length) documentAttributes:exportParams error:nil];
    NSString *exportHtmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    [EUtility saveContentToFileWithContent:exportHtmlString guid:self.guid];
    
    self.contentTextView.attributedText = attributedText_;
    
    self.contentTextView.selectedRange = NSMakeRange(0, 0);
}

@end

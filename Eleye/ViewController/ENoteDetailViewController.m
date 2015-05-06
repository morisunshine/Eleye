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


@interface ENoteDetailViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *highlightRanges_;
    NSMutableAttributedString *attributedText_;
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
    attributedText_ = [[NSMutableAttributedString alloc] initWithAttributedString:[EUtility stringFromLocalPathWithGuid:self.guid]];
    [self customStyleWithContent];
}

- (void)customStyleWithContent
{
    [attributedText_ enumerateAttributesInRange:NSMakeRange(0, attributedText_.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSLog(@"attrs:%@ range:%@, %@, text:%@", attrs, @(range.location), @(range.length), [attributedText_.string substringWithRange:range]);
        UIFont *font = [attrs objectForKey:NSFontAttributeName];
        if (font.pointSize < 17) {
            font = [UIFont systemFontOfSize:14];
        } else {
            font = [UIFont systemFontOfSize:18];
        }
        NSParagraphStyle *paragraphStyle = [attrs objectForKey:NSParagraphStyleAttributeName];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{NSBackgroundColorAttributeName: [UIColor whiteColor],
                                                                                   NSFontAttributeName: font,
                                                                                   NSParagraphStyleAttributeName: paragraphStyle,
                                                                                   NSForegroundColorAttributeName: RGBCOLOR(75, 75, 75)}];
        if ([attrs objectForKey:NSLinkAttributeName]) {
            [dic setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
            [dic setObject:RGBCOLOR(168, 87, 48) forKey:NSForegroundColorAttributeName];
            [dic setObject:[attributedText_.string substringWithRange:range] forKey:NSLinkAttributeName];
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
    NSLog(@"vel:%@", NSStringFromCGPoint(vel));
    if (vel.x > 50) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)tapGR:(UITapGestureRecognizer *)sender
{
//    CGPoint location = [sender locationInView:sender.view];
//    CGRect tapRect = CGRectMake(location.x - 30, location.y - 30, 60, 60);
//    NSRange range = [self.contentTextView.layoutManager glyphRangeForBoundingRect:tapRect inTextContainer:self.contentTextView.textContainer];
//
//    for (NSIndexPath *indexPath in highlightRanges_) {
//        NSInteger location = indexPath.row;
//        NSInteger length = indexPath.section;
//        
//        if (location <= range.location + range.length || range.location <= location + length) {
//            NSLog(@"选中有高亮");
//        }
//    }
}

- (void)cBtnTapped
{
    NSString *selectedText = [self.contentTextView.text substringWithRange:self.contentTextView.selectedRange];
    [UIPasteboard generalPasteboard].string = selectedText;
}

- (void)highlightTextViewWithHighlight:(BOOL)highlight
{
    NSRange selectedRange = self.contentTextView.selectedRange;
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *dict;
    
    if (highlight) {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRange.location inSection:selectedRange.length];
        [highlightRanges_ addObject:selectedIndexPath];
        dict = @{NSBackgroundColorAttributeName: RGBACOLOR(168, 87, 48, 0.3), NSFontAttributeName: font};
    } else {
        dict = @{NSBackgroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: font};
    }
    
    [self.contentTextView.textStorage beginEditing];
    [self.contentTextView.textStorage setAttributes:dict range:selectedRange];
    [self.contentTextView.textStorage endEditing];
    
    [attributedText_ enumerateAttributesInRange:selectedRange options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         [mutableAttributes setObject:RGBACOLOR(168, 87, 48, 0.3) forKey:NSBackgroundColorAttributeName];
         [attributedText_ setAttributes:mutableAttributes range:range];
     }];
    
    self.contentTextView.selectedRange = NSMakeRange(0, 0);
}

@end

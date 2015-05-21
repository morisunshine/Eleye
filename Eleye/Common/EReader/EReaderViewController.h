//
//  ZSSRichTextEditorViewController.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The viewController used with ZSSRichTextEditor
 */
@interface EReaderViewController : UIViewController <UIWebViewDelegate, UITextViewDelegate>


/**
 *  The base URL to use for the webView
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;

@property (nonatomic, strong) UIWebView *editorView;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(NSString *)html;

/**
 *  Sets the TopTitle of the reader
 * 
 *  @param title title of Note
 */
- (void)changeTopTitle:(NSString *)title;

/**
 *  Returns the HTML from the Rich Text Editor
 *
 */
- (NSString *)getHTML;

/**
 *  Returns the plain text from the Rich Text Editor
 *
 */
- (NSString *)getText;

/**
 *  add the highlight
 */
- (void)addHighlight;

/**
 *  remove the highlight
 */
- (void)cancelHighlight;

@end

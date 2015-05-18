//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "ZSSRichTextEditor.h"
#import "HRColorUtil.h"


//@interface UIWebView (HackishAccessoryHiding)
//@property (nonatomic, assign) BOOL hidesInputAccessoryView;
//@end
//
//@implementation UIWebView (HackishAccessoryHiding)
//
//static const char * const hackishFixClassName = "UIWebBrowserViewMinusAccessoryView";
//static Class hackishFixClass = Nil;
//
//- (UIView *)hackishlyFoundBrowserView {
//    UIScrollView *scrollView = self.scrollView;
//    
//    UIView *browserView = nil;
//    for (UIView *subview in scrollView.subviews) {
//        if ([NSStringFromClass([subview class]) hasPrefix:@"UIWebBrowserView"]) {
//            browserView = subview;
//            break;
//        }
//    }
//    return browserView;
//}
//
//- (id)methodReturningNil {
//    return nil;
//}
//
//- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
//    if (!hackishFixClass) {
//        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
//        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
//        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
//        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
//        objc_registerClassPair(newClass);
//        
//        hackishFixClass = newClass;
//    }
//}
//
//- (BOOL) hidesInputAccessoryView {
//    UIView *browserView = [self hackishlyFoundBrowserView];
//    return [browserView class] == hackishFixClass;
//}
//
//- (void) setHidesInputAccessoryView:(BOOL)value {
//    UIView *browserView = [self hackishlyFoundBrowserView];
//    if (browserView == nil) {
//        return;
//    }
//    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
//    
//    if (value) {
//        object_setClass(browserView, hackishFixClass);
//    }
//    else {
//        Class normalClass = objc_getClass("UIWebBrowserView");
//        object_setClass(browserView, normalClass);
//    }
//    [browserView reloadInputViews];
//}
//
//@end

@interface ZSSRichTextEditor ()
{
    NSString *htmlString_;
}

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic) CGRect editorViewFrame;
@property (nonatomic) BOOL resourcesLoaded;
@property (nonatomic, strong) NSString *selectedLinkURL;
@property (nonatomic, strong) NSString *selectedLinkTitle;
@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) NSString *selectedImageAlt;
@property (nonatomic, strong) NSString *internalHTML;
@property (nonatomic, strong) NSString *topTitle;
@property (nonatomic, strong) NSString *internalTitle;
@property (nonatomic) BOOL editorLoaded;
- (NSString *)removeQuotesFromHTML:(NSString *)html;
- (NSString *)tidyHTML:(NSString *)html;

@end

@implementation ZSSRichTextEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editorLoaded = NO;
    self.formatHTML = YES;
    
    // Source View
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    // Editor View
    self.editorView = [[UIWebView alloc] initWithFrame:frame];
    self.editorView.delegate = self;
    self.editorView.scalesPageToFit = YES;
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.editorView.scrollView.bounces = NO;
    self.editorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.editorView];
    
    if (!self.resourcesLoaded) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
        NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
        NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];

        // ZSSRichTextEditor.js
        NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
        NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];

        // jquery.js
        NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"main.min" ofType:@"js"];
        NSString *jsData = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jsPath] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--js-->" withString:jsData];

        // main.css
        NSString *cssPathMain   = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"css"];
        NSString *cssDataMain = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:cssPathMain] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"/*main*/" withString:cssDataMain];
        
        [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
        self.resourcesLoaded = YES;
    }
}

- (void)setPlaceholderText {
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
    
}

- (void)setFooterHeight:(float)footerHeight {
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setContentHeight:(float)contentHeight {
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Editor Interaction

- (void)focusTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)changeTopTitle:(NSString *)title
{
    self.topTitle = title;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
}

- (void)setHTML:(NSString *)html {
    
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
    
}

- (void)updateHTML {
    
    NSString *html = self.internalHTML;
    htmlString_ = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:htmlString_];
    NSString *htmlTrigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    NSString *titleTrigger = [NSString stringWithFormat:@"zss_editor.setTopTitle(\"%@\");", self.topTitle];
    
    [self.editorView stringByEvaluatingJavaScriptFromString:titleTrigger];
    [self.editorView stringByEvaluatingJavaScriptFromString:htmlTrigger];
    
}

- (NSString *)getHTML {
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getHTML();"];
    html = [self removeQuotesFromHTML:html];
    html = [self tidyHTML:html];
    return html;
}


- (void)insertHTML:(NSString *)html {
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (NSString *)getText {
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getText();"];
}

- (void)showHTMLSource:(ZSSBarButtonItem *)barButtonItem {
//    if (barButtonItem.sho) {
//        htmlString_ = [self getHTML];
//    } else {
//        [self setHTML:htmlString_];
//    }
}

- (void)removeFormat {
    NSString *trigger = @"zss_editor.removeFormating();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignFull {
    NSString *trigger = @"zss_editor.setJustifyFull();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSubscript {
    NSString *trigger = @"zss_editor.setSubscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSuperscript {
    NSString *trigger = @"zss_editor.setSuperscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setStrikethrough {
    NSString *trigger = @"zss_editor.setStrikeThrough();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOrderedList {
    NSString *trigger = @"zss_editor.setOrderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setHR {
    NSString *trigger = @"zss_editor.setHorizontalRule();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading1 {
    NSString *trigger = @"zss_editor.setHeading('h1');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading5 {
    NSString *trigger = @"zss_editor.setHeading('h5');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading6 {
    NSString *trigger = @"zss_editor.setHeading('h6');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)paragraph {
    NSString *trigger = @"zss_editor.setParagraph();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)textColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 1;
    colorPicker.title = NSLocalizedString(@"Text Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)bgColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 2;
    colorPicker.title = NSLocalizedString(@"BG Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag {
    
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.undo();"];
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.redo();"];
}

- (void)insertLink {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Show the dialog for inserting or editing a link
    [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
    
}

- (void)addHighlight
{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.addHilite()"];
    
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Title", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (title) {
                textField.text = title;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *linkURL = [alertController.textFields objectAtIndex:0];
            UITextField *title = [alertController.textFields objectAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
                NSLog(@"insert link");
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
    }
    
}


- (void)insertLink:(NSString *)url title:(NSString *)title {
    
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}


- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)removeLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.unlink();"];
}//end

- (void)quickLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.quickLink();"];
}

- (void)insertImage {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    [self showInsertImageDialogWithLink:self.selectedImageURL alt:self.selectedImageAlt];
    
}

- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertImageAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *imageURL = [alertController.textFields objectAtIndex:0];
            UITextField *alt = [alertController.textFields objectAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
    }
    
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


- (void)updateToolBarWithButtonName:(NSString *)name {
    
//    // Items that are enabled
//    NSArray *itemNames = [name componentsSeparatedByString:@","];
//    
//    // Special case for link
//    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
//    for (NSString *linkItem in itemNames) {
//        NSString *updatedItem = linkItem;
//        if ([linkItem hasPrefix:@"link:"]) {
//            updatedItem = @"link";
//            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
//        } else if ([linkItem hasPrefix:@"link-title:"]) {
//            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
//        } else if ([linkItem hasPrefix:@"image:"]) {
//            updatedItem = @"image";
//            self.selectedImageURL = [linkItem stringByReplacingOccurrencesOfString:@"image:" withString:@""];
//        } else if ([linkItem hasPrefix:@"image-alt:"]) {
//            self.selectedImageAlt = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
//        } else {
//            self.selectedImageURL = nil;
//            self.selectedImageAlt = nil;
//            self.selectedLinkURL = nil;
//            self.selectedLinkTitle = nil;
//        }
//        [itemsModified addObject:updatedItem];
//    }
//    itemNames = [NSArray arrayWithArray:itemsModified];
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"web request");
    NSLog(@"%@", urlString);
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *debug = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"%@", debug);
        
    } else if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        [self editorDidScrollWithPosition:position];
        
    }
    
    return YES;
    
}//end


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.editorLoaded = YES;
    //[self setPlaceholderText];
    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];
}

#pragma mark - Callbacks

// Blank implementation
- (void)editorDidScrollWithPosition:(NSInteger)position {
    
}

#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}


- (void)showInsertImageAlternatePicker {
    // Blank method. User should implement this in their subclass
}


#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}//end


- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
}//end

- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end

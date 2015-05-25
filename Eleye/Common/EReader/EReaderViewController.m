//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "EReaderViewController.h"

@interface EReaderViewController ()
{
    NSString *htmlString_;
}

@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic) CGRect editorViewFrame;
@property (nonatomic) BOOL resourcesLoaded;
@property (nonatomic, strong) NSString *internalHTML;
@property (nonatomic, strong) NSString *topTitle;
@property (nonatomic) BOOL editorLoaded;

- (NSString *)removeQuotesFromHTML:(NSString *)html;
- (NSString *)tidyHTML:(NSString *)html;

@end

@implementation EReaderViewController

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
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"reader" ofType:@"html"];
        NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
        NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];

        // import js file
        NSString *source = [[NSBundle mainBundle] pathForResource:@"main.min" ofType:@"js"];
        NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--js-->" withString:jsString];

        // main.css
        NSString *cssPathMain   = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"css"];
        NSString *cssDataMain = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:cssPathMain] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"/*css*/" withString:cssDataMain];
        
        [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
        self.resourcesLoaded = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Editor Interaction

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
    NSString *htmlTrigger = [NSString stringWithFormat:@"EReader.setHTML(\"%@\");", cleanedHTML];
    NSString *titleTrigger = [NSString stringWithFormat:@"EReader.setTopTitle(\"%@\");", self.topTitle];
    
    [self.editorView stringByEvaluatingJavaScriptFromString:titleTrigger];
    [self.editorView stringByEvaluatingJavaScriptFromString:htmlTrigger];
}

- (NSString *)getHTML {
    
    NSString *evernoteDocument = @"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">";
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"EReader.getHTML();"];
    html = [html stringByReplacingOccurrencesOfString:@"<!--?" withString:@"<?"];
    html = [html stringByReplacingOccurrencesOfString:@"?-->" withString:@"?>"];
    html = [[html componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:evernoteDocument];
    
    return html;
}

- (NSString *)getText {
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"EReader.getText();"];
}

- (void)removeFormat {
    NSString *trigger = @"EReader.removeFormating();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag 
{    
    NSString *hex = @"#c0c0c0";
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"EReader.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"EReader.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)addHighlight
{
    NSString *trigger = [NSString stringWithFormat:@"EReader.addHilite()"];
    
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)cancelHighlight
{
    NSString *trigger = [NSString stringWithFormat:@"EReader.removeHilite()"];
    
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"web request");
    NSLog(@"%@", urlString);
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[Mixpanel sharedInstance] track:@"点击外部链接"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        NSLog(@"%@", className);
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *debug = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"%@", debug);
        
    } 
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    self.editorLoaded = YES;
    
    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    
    [self updateHTML];
}

#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    
    return html;
}

- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    
    return html;
}

- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end

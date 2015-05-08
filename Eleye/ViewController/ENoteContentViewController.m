//
//  ENoteContentViewController.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteContentViewController.h"
#import <TFHpple.h>

@interface ENoteContentViewController ()

@end

@implementation ENoteContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *string = [EUtility contentFromLocalPathWithGuid:self.guid];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//h2"];
    TFHppleElement *element = [elements firstObject];
    NSLog(@"text %@", element.text);
    NSLog(@"attributes %@", element.attributes);

    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSLog(@"%@, %@, %@", substring, @(substringRange.location), @(substringRange.length));
    }];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

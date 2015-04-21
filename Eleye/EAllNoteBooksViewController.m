//
//  EAllNoteBooksViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNoteBooksViewController.h"
#import "ENotebookStackView.h"
#import <ENSDKAdvanced.h>

@interface EAllNoteBooksViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary *notebooks_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *usernameBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end

@implementation EAllNoteBooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client listNotebooksWithSuccess:^(NSArray *notebooks) {
        
        notebooks_ = [[NSMutableDictionary alloc] init];
        
        for (EDAMNotebook *notebook in notebooks) {
            if (notebook.stack == nil) {
                [notebooks_ setObject:notebook forKey:notebook.name];
            } else {
                NSMutableArray *subNotebooks = [notebooks_ objectForKey:notebook.stack];
                if (subNotebooks) {
                    [subNotebooks addObject:notebook];
                } else {
                    subNotebooks = [[NSMutableArray alloc] init];
                    [subNotebooks addObject:notebook];
                    [notebooks_ setObject:subNotebooks forKey:notebook.stack];
                }
            }
        }
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记本数据错误:%@", error);
        }
    }];

    [self.usernameBtn setTitle:[ENSession sharedSession].userDisplayName forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return notebooks_.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = notebooks_.allKeys[section];
    NSInteger count = 0;
    id value = [notebooks_ objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *subNotebooks = [notebooks_ objectForKey:key];
        count = subNotebooks.count;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 49;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ENotebookStackView *stackView = [[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil][0];
    stackView.stackNameLabel.text = notebooks_.allKeys[section];
    
    return stackView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"notebookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    
    NSString *key = notebooks_.allKeys[indexPath.section];
    NSArray *subNotebook = [notebooks_ objectForKey:key];
    EDAMNotebook *notebook = subNotebook[indexPath.row];
    titleLabel.text = notebook.name;
    
    return cell;
}

@end

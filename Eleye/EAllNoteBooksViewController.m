//
//  EAllNoteBooksViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNoteBooksViewController.h"
#import <ENSDKAdvanced.h>

@interface EAllNoteBooksViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *notebooks_;
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
        notebooks_ = notebooks;
        
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notebooks_.count;
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
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"notebookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    
    EDAMNotebook *book = notebooks_[indexPath.row];
    titleLabel.text = book.name;
    
    return cell;
}

@end

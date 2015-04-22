//
//  EAllNoteBooksViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNoteBooksViewController.h"
#import "ENotebookStackView.h"
#import "EAllNotesViewController.h"
#import <ENSDKAdvanced.h>

static CGFloat kCellHeight = 49;

@interface EAllNoteBooksViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSMutableDictionary *notebooks_;
    NSMutableDictionary *viewStatus_;
    UIAlertView *alertView_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *usernameBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation EAllNoteBooksViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self listNotebooks];
    [self configureUI];
    [self.usernameBtn setTitle:[ENSession sharedSession].userDisplayName forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters -

- (UIRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

#pragma mark - Private Methods -

- (void)configureUI
{
    NSString *title = [NSString stringWithFormat:@"V%@ 问题反馈", APP_VERSION];
    
    [self.feedbackBtn setTitle:title forState:UIControlStateNormal];
    [self.tableView addSubview:self.refreshControl];
    [EUtility addlineOnView:self.tableView position:EViewPositionTop];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)listNotebooks
{
    [self.refreshControl endRefreshing];
    
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client listNotebooksWithSuccess:^(NSArray *notebooks) {
        
        notebooks_ = [[NSMutableDictionary alloc] init];
        viewStatus_ = [[NSMutableDictionary alloc] init];
        
        EDAMNotebook *allnoteBook = [[EDAMNotebook alloc] init];
        allnoteBook.guid = nil;
        allnoteBook.name = @"All notes";
        [notebooks_ setObject:allnoteBook forKey:allnoteBook.name];
        
        for (EDAMNotebook *notebook in notebooks) {
            if (notebook.stack == nil) {
                [notebooks_ setObject:notebook forKey:notebook.name];
            } else {
                [viewStatus_ setObject:@(YES) forKey:notebook.stack];
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
}

- (void)handleViewWithIndex:(NSInteger)section
{
    NSString *key = notebooks_.allKeys[section];
    id value = [notebooks_ objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        BOOL isOpen = [[viewStatus_ objectForKey:key] boolValue];
        NSArray *subNotebooks = [notebooks_ objectForKey:key];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (NSInteger i = 0;i < subNotebooks.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [indexPaths addObject:indexPath];
        }
        if (isOpen == YES) {
            [viewStatus_ setObject:key forKey:@(NO)];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [viewStatus_ setObject:key forKey:@(YES)];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
    } else {
        EDAMNotebook *notebook = (EDAMNotebook *)value;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EAllNotesViewController *allNotebookViewController = [story instantiateViewControllerWithIdentifier:@"EAllNotesViewController"];
        allNotebookViewController.guid = notebook.guid;
        allNotebookViewController.notebookName = notebook.name;
        [self.navigationController pushViewController:allNotebookViewController animated:YES];
    }
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
        BOOL isOpen = [[viewStatus_ objectForKey:key] boolValue];
        if (isOpen == YES) {
            NSArray *subNotebooks = [notebooks_ objectForKey:key];
            count = subNotebooks.count;
        } else {
            count = 0;
        }
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ENotebookStackView *stackView = [[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil][0];
    stackView.stackNameLabel.text = notebooks_.allKeys[section];
    stackView.viewBtn.tag = 100 + section;
    stackView.btnHandler = ^(NSInteger index) {
        [self handleViewWithIndex:index];
    };
    
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
    [EUtility addlineOnView:cell position:EViewPositionBottom insert:17];
    
    return cell;
}

#pragma mark - TableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = notebooks_.allKeys[indexPath.section];
    NSArray *subNotebook = [notebooks_ objectForKey:key];
    EDAMNotebook *notebook = subNotebook[indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EAllNotesViewController *allNotebookViewController = [story instantiateViewControllerWithIdentifier:@"EAllNotesViewController"];
    allNotebookViewController.guid = notebook.guid;
    allNotebookViewController.notebookName = notebook.name;
    [self.navigationController pushViewController:allNotebookViewController animated:YES];
}

#pragma mark - Actions -

- (IBAction)logoutBtnTapped:(id)sender {
    alertView_ = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    [alertView_ show];
}

- (IBAction)refreshControlChanged:(UIRefreshControl *)sender
{
    [self listNotebooks];
}

- (IBAction)feedbackBtnTapped:(id)sender 
{
    
}

#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[ENSession sharedSession] unauthenticate];
        //TODO 清除数据库, 退回到登录页面
    }
}

@end

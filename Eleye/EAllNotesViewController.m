//
//  EAllNotesViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNotesViewController.h"
#import "ENoteCell.h"
#import <SVPullToRefresh.h>

static int32_t kMaxCount = 20;

@interface EAllNotesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *notes_;
    int32_t offset_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *notebookNameBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation EAllNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notebookNameBtn setTitle:self.notebookName forState:UIControlStateNormal];
    
    
    [self configureUI];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -

- (void)listNotesLoadingMore:(BOOL)loadingMore
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
    filter.notebookGuid = self.guid;
    EDAMRelatedQuery *query = [[EDAMRelatedQuery alloc] init];
    query.filter = filter;
    
    if (loadingMore) {
        
    } else {
        offset_ = 0;
    }
    
    [client findNotesWithFilter:filter offset:offset_ maxNotes:kMaxCount success:^(EDAMNoteList *list) {
        NSInteger totalCount = [list.totalNotes integerValue];
        
        notes_ = list.notes;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取失败");
        }
    }];
}

- (void)configureUI
{
    [EUtility addlineOnView:self.headerView position:EViewPositionBottom];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Actions -

- (IBAction)allNotesBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notes_.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"noteCell";
    ENoteCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    EDAMNote *note = notes_[indexPath.row];
    
    [cell updateUIWithNote:note];
    
    return cell;
}

#pragma mark - TableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

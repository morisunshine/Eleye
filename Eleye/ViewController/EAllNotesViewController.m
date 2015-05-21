//
//  EAllNotesViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNotesViewController.h"
#import "ENoteViewController.h"
#import "ENoteCell.h"
#import <SVPullToRefresh.h>
#import "ENoteDAO.h"

static int32_t kMaxCount = 20;
static NSInteger kCellHeight = 100;

@interface EAllNotesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *notes_;
    int32_t offset_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *notebookNameBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation EAllNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notebookNameBtn setTitle:self.notebookName forState:UIControlStateNormal];
    
    __weak EAllNotesViewController *weakSelf = self;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf listNotesLoadingMore:YES];
    }];
    
    notes_ = [[ENoteDAO sharedENoteDAO] notesWithNotebookGuid:self.guid];
    self.tableView.showsInfiniteScrolling = NO;
    
    [self listNotesLoadingMore:NO];
    [self configureUI];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotesWithNotification) name:UPDATENOTENOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotesWithNotification) name:UPDATENOTELISTNOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)updateNotesWithNotification
{
    notes_ = [[ENoteDAO sharedENoteDAO] notesWithNotebookGuid:self.guid];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)listNotesLoadingMore:(BOOL)loadingMore
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
    filter.notebookGuid = self.guid;
    filter.order = @(NoteSortOrder_UPDATED);
    filter.ascending = @(NO);
    EDAMRelatedQuery *query = [[EDAMRelatedQuery alloc] init];
    query.filter = filter;
    
    if (loadingMore == NO) {
        offset_ = 0;
    }
    [client findNotesWithFilter:filter offset:offset_ maxNotes:kMaxCount success:^(EDAMNoteList *list) {
        [self.refreshControl endRefreshing];
        int32_t totalCount = [list.totalNotes intValue];
        int32_t startIndex = [list.startIndex intValue];
        if (kMaxCount < totalCount - startIndex) {
            offset_ = startIndex + kMaxCount + 1;
            self.tableView.showsInfiniteScrolling = YES;
        } else {
            self.tableView.showsInfiniteScrolling = NO;
        }
        
        if (loadingMore) {
            NSMutableArray *mutNotes = [NSMutableArray arrayWithArray:notes_];
            [mutNotes addObjectsFromArray:list.notes];
            notes_ = mutNotes;
        } else {
            notes_ = list.notes;
        }
        
        [[ENoteDAO sharedENoteDAO] saveItems:list.notes];
        
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
    [self.tableView addSubview:self.refreshControl];
}

- (void)updateNoteWithNote:(EDAMNote *)note indexPath:(NSIndexPath *)indexPath
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client getNoteWithGuid:note.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *enote) {
        ENNote * resultNote = [[ENNote alloc] initWithServiceNote:enote];
        NSString *contentString = [resultNote.content enmlWithNote:resultNote];
        [[EUtility sharedEUtility] saveContentToFileWithContent:contentString guid:note.guid];
        [EUtility saveDataBaseResources:resultNote.resources withNoteGuid:note.guid];
        NSString *noteString = [EUtility noteContentWithGuid:note.guid];
        note.content = [noteString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [EUtility removeValueWithKey:note.guid fileName:REMOTEUPDATEDTITLE];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记内容错误%@", error);
        }
    }];
}

#pragma mark - Actions -

- (IBAction)allNotesBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refreshControlChanged:(UIRefreshControl *)sender
{
    [self listNotesLoadingMore:NO];
}

#pragma mark - TableView DataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notes_.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"noteCell";
    ENoteCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    EDAMNote *note = notes_[indexPath.row];
    
    if (note.content == nil) {
        NSString *contentString = [EUtility noteContentWithGuid:note.guid];
        if (contentString) {
            if ([EUtility valueWithKey:note.guid fileName:REMOTEUPDATEDTITLE]) {
                [self updateNoteWithNote:note indexPath:indexPath];
            } else {
                note.content = [contentString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            }
        } else {
            [self updateNoteWithNote:note indexPath:indexPath];
        }
    }
    
    [cell updateUIWithNote:note];
    
    return cell;
}

#pragma mark - TableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[Mixpanel sharedInstance] track:@"点击文章详情"];

    ENoteViewController *noteViewController = [[ENoteViewController alloc] init];
    EDAMNote *note = notes_[indexPath.row];
    noteViewController.noteTitle = note.title;
    noteViewController.guid = note.guid;
    [self.navigationController pushViewController:noteViewController animated:YES];
}

@end

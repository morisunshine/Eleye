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
    
    [self listNotesLoadingMore:NO];
    [self configureUI];

    // Do any additional setup after loading the view from its nib.
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

- (void)listNotesLoadingMore:(BOOL)loadingMore
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
    filter.notebookGuid = self.guid;
    EDAMRelatedQuery *query = [[EDAMRelatedQuery alloc] init];
    query.filter = filter;
    
    if (loadingMore) {
        self.tableView.showsInfiniteScrolling = YES;
    } else {
        offset_ = 0;
    }
    
    [client findNotesWithFilter:filter offset:offset_ maxNotes:kMaxCount success:^(EDAMNoteList *list) {
        NSArray *newNotes = [self newNotesFromNotes:list.notes];
        
        [self.refreshControl endRefreshing];
        int32_t totalCount = [list.totalNotes intValue];
        int32_t startIndex = [list.startIndex intValue];
        if (kMaxCount < totalCount - startIndex) {
            offset_ = startIndex + kMaxCount + 1;
        } else {
            self.tableView.showsInfiniteScrolling = NO;
        }
        
        if (loadingMore) {
            notes_ = newNotes;
        } else {
            NSMutableArray *mutNotes = [NSMutableArray arrayWithArray:notes_];
            [mutNotes addObjectsFromArray:newNotes];
            notes_ = mutNotes;
        }
        
        for (ENoteDO *note in newNotes) {
            [client getNoteWithGuid:note.guid withContent:YES withResourcesData:YES withResourcesRecognition:YES withResourcesAlternateData:YES success:^(EDAMNote *note) {
                NSLog(@"%@", note.content);
            } failure:^(NSError *error) {
                
            }];
        }
        
        [[ENoteDAO sharedENoteDAO] saveItems:newNotes];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取失败");
        }
    }];
}

- (NSArray *)newNotesFromNotes:(NSArray *)notes
{
    NSMutableArray *newNotes = [[NSMutableArray alloc] init];
    for (EDAMNote *note in notes) {
        ENoteDO *newNote = [[ENoteDO alloc] init];
        newNote.title = note.title;
        newNote.notebookGuid = note.notebookGuid;
        newNote.content = note.content;
        newNote.created = note.created;
        newNote.updated = note.updated;
        newNote.deleted = note.deleted;
        newNote.active = note.active;
        newNote.guid = note.guid;
        
        [newNotes addObject:newNote];
    }
    
    return newNotes;
}

- (void)configureUI
{
    [EUtility addlineOnView:self.headerView position:EViewPositionBottom];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView addSubview:self.refreshControl];
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
    
    ENoteDO *note = notes_[indexPath.row];
    
    [cell updateUIWithNote:note];
    
    return cell;
}

#pragma mark - TableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

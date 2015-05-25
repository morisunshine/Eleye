//
//  EAllNoteBooksViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNoteBooksViewController.h"
#import "ENotebookStackView.h"
#import "ENotebookCell.h"
#import "EAllNotesViewController.h"
#import "ENotebookDAO.h"
#import "ENoteDAO.h"
#import "ELoginViewController.h"
#import <MessageUI/MessageUI.h>
#import "MHNavigationController.h"
#import "ENoteUpdateManager.h"

static CGFloat kCellHeight = 49;

@interface EAllNoteBooksViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
{
    NSMutableDictionary *stackDics_;
    NSMutableArray *mutNotebooks_;
    NSMutableDictionary *notebookCounts_;
    NSMutableDictionary *notebooks_;
    NSMutableDictionary *viewStatus_;
    UIAlertView *alertView_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *usernameBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation EAllNoteBooksViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self getsyncState];
    [self getNotebookCounts];
    [self configureUI];
    [self.usernameBtn setTitle:[ENSession sharedSession].userDisplayName forState:UIControlStateNormal];
    
    if (self.showAllNotes) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EAllNotesViewController *allNotebookViewController = [story instantiateViewControllerWithIdentifier:@"EAllNotesViewController"];
        allNotebookViewController.guid = nil;
        allNotebookViewController.notebookName = @"All notes";
        [(MHNavigationController *)self.navigationController customPushViewController:allNotebookViewController fromViewController:self];
    }
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

- (void)getsyncState
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;

    EDAMSyncChunkFilter *filter = [[EDAMSyncChunkFilter alloc] init];
    filter.includeNotebooks = @(YES);
    filter.includeNotes = @(YES);
    filter.includeNoteResources = @(YES);
    filter.includePreferences = @(YES);
    NSNumber *chunkHighUSN = [USER_DEFAULT objectForKey:@"chunkUSN"];
    int32_t afterUSN = 0;
    if (chunkHighUSN) {
        afterUSN = [chunkHighUSN intValue];
    } 
    [client getFilteredSyncChunkAfterUSN:afterUSN maxEntries:100 filter:filter success:^(EDAMSyncChunk *syncChunk) {
        if (0 < syncChunk.resources) {
            NSLog(@"笔记中的资源文件有更新！");
        }
        if (0 < syncChunk.notebooks) {
            
        }
        if (0 < syncChunk.notes) {
            NSLog(@"有更新！");
            
            for (EDAMNote *note in syncChunk.notes) {
                if (note.deleted) {
                    [EUtility deleteNotePathWithGuid:note.guid];
                    [[ENoteDAO sharedENoteDAO] deleteNoteWithGuid:note.guid];
                } else {
                    NSNumber *updateNume = [EUtility valueWithKey:note.guid fileName:LOCALUPDATEFILE];
                    if (updateNume) {
                        if ([updateNume integerValue] < [note.updated integerValue]) {
                            [EUtility setSafeValue:@(NO) key:note.guid fileName:REMOTEUPDATEDTITLE];
                        }
                        [EUtility removeValueWithKey:note.guid fileName:LOCALUPDATEFILE];
                    } else {
                        [EUtility setSafeValue:@(NO) key:note.guid fileName:REMOTEUPDATEDTITLE];
                    }
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATENOTENOTIFICATION object:nil];
        }
        
        [[ENoteUpdateManager sharedENoteUpdateManager] checkUnUploadNotes];
        
        NSNumber *newChunkHighUSN = syncChunk.chunkHighUSN;
        [USER_DEFAULT setObject:newChunkHighUSN forKey:@"chunkUSN"];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取同步信息失败:%@", error);
        }
    }];
}

- (void)configureUI
{
    NSString *title = [NSString stringWithFormat:@"V%@ %@", APP_VERSION, LOCALSTRING(@"Feedback")];
    
    [EUtility addlineOnView:self.headerView position:EViewPositionBottom];
    [EUtility addlineOnView:self.footerView position:EViewPositionTop];
    [self.tableView addSubview:self.refreshControl];
    [self.feedbackBtn setTitle:title forState:UIControlStateNormal];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)listNotebooks
{
    [self.refreshControl endRefreshing];
    
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client listNotebooksWithSuccess:^(NSArray *notebooks) {
        [[ENotebookDAO sharedENotebookDAO] deleteAllNoteBooks];
        NSArray *newNotebooks = [self newNotebooksFromNotebooks:notebooks];
        [[ENotebookDAO sharedENotebookDAO] saveItems:newNotebooks];
        [self doneloadWithNotebooks:newNotebooks];
        
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取笔记本数据错误:%@", error);
        }
    }];
}

- (void)getNotebookCounts
{
    //先获取数据库中的数据
    [self getNotebooksFromDB];
    
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
    filter.notebookGuid = nil;//获取所有笔记本的数量
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    [client findNoteCountsWithFilter:filter withTrash:NO success:^(EDAMNoteCollectionCounts *counts) {
        notebookCounts_ = [NSMutableDictionary dictionaryWithDictionary:counts.notebookCounts];
        [self listNotebooks];
    } failure:^(NSError *error) {
        [self listNotebooks];
        if (error) {
            NSLog(@"获取数量失败");
        }
    }];
}

- (NSMutableArray *)newNotebooksFromNotebooks:(NSArray *)notebooks
{
    NSMutableArray *newNotebooks = [[NSMutableArray alloc] init];
    
    for (EDAMNotebook *notebook in notebooks) {
        ENoteBookDO *newnotebook = [[ENoteBookDO alloc] init];
        newnotebook.guid = notebook.guid;
        newnotebook.name = notebook.name;
        newnotebook.published = notebook.published;
        newnotebook.stack = notebook.stack;
        newnotebook.serviceCreated = notebook.serviceCreated;
        newnotebook.serviceUpdated = notebook.serviceUpdated;
        newnotebook.count = [notebookCounts_ objectForKey:notebook.guid];
        
        [newNotebooks addObject:newnotebook];
    }
    
    return newNotebooks;
}

- (void)getNotebooksFromDB
{
    NSArray *notebooks = [[ENotebookDAO sharedENotebookDAO] notebooks];
    notebookCounts_ = [[NSMutableDictionary alloc] init];
    
    for (ENoteBookDO *notebook in notebooks) {
        [notebookCounts_ setObject:notebook.count forKey:notebook.guid];
    }
    
    [self doneloadWithNotebooks:notebooks];
}

- (void)doneloadWithNotebooks:(NSArray *)notebooks
{
    mutNotebooks_ = [[NSMutableArray alloc] init];
    notebooks_ = [[NSMutableDictionary alloc] init];
    viewStatus_ = [[NSMutableDictionary alloc] init];
    stackDics_ = [[NSMutableDictionary alloc] init];
    
    ENoteBookDO *allnoteBook = [[ENoteBookDO alloc] init];
    allnoteBook.guid = nil;
    allnoteBook.name = @"All notes";
    NSInteger totalCount = 0;
    for (NSNumber *count in notebookCounts_.allValues) {
        totalCount += [count integerValue];
    }
    allnoteBook.count = @(totalCount);
    [mutNotebooks_ addObject:allnoteBook];
    
    for (ENoteBookDO *notebook in notebooks) {
        NSNumber *count = [notebookCounts_ objectForKey:notebook.guid];
        notebook.count = count;
        if (notebook.stack == nil) {
            [mutNotebooks_ addObject:notebook];
        } else {
            NSMutableArray *subNotebooks = [notebooks_ objectForKey:notebook.stack];
            ENoteBookDO *stackNotebook;
            if (!subNotebooks) {
                [viewStatus_ setObject:@(YES) forKey:notebook.stack];
                subNotebooks = [[NSMutableArray alloc] init];
                stackNotebook = [[ENoteBookDO alloc] init];
                stackNotebook.name = notebook.stack;
                stackNotebook.stack = notebook.stack;
                stackNotebook.count = count;
                [stackDics_ setObject:stackNotebook forKey:notebook.stack];
                [mutNotebooks_ addObject:stackNotebook];
            } else {
                stackNotebook = [stackDics_ objectForKey:notebook.stack];
                NSInteger totalCount = [stackNotebook.count integerValue] + [count integerValue];
                stackNotebook.count = @(totalCount);
            }
            
            [subNotebooks addObject:notebook];
            [notebooks_ setObject:subNotebooks forKey:notebook.stack];
        }
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)handleViewWithIndex:(NSInteger)section
{
    ENoteBookDO *notebook = mutNotebooks_[section];
    if (notebook.stack) {
        
    } else {
        [[Mixpanel sharedInstance] track:@"点击笔记本列表"];
        
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
    return mutNotebooks_.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ENoteBookDO *notebook = mutNotebooks_[section];
    
    NSInteger count = 0;
    
    if (notebook.stack) {
        BOOL isOpen = [[viewStatus_ objectForKey:notebook.stack] boolValue];
        if (isOpen) {
            NSArray *subNotebooks = [notebooks_ objectForKey:notebook.stack];
            count = subNotebooks.count;
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
    ENoteBookDO *notebook = mutNotebooks_[section];
    
    ENotebookStackView *stackView = [[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:nil][0];
    
    [stackView updateUIWithNotebook:notebook];
    stackView.viewBtn.tag = 100 + section;
    stackView.btnHandler = ^(NSInteger index) {
        [self handleViewWithIndex:index];
    };
    
    return stackView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"notebookCell";
    
    ENotebookCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ENoteBookDO *notebook = mutNotebooks_[indexPath.section];
    
    if (notebook.stack) {
        BOOL isOpen = [[viewStatus_ objectForKey:notebook.stack] boolValue];
        if (isOpen) {
            NSArray *subNotebooks = [notebooks_ objectForKey:notebook.stack];
            ENoteBookDO *subNotebook = subNotebooks[indexPath.row];
            [cell updateUIWithNotebook:subNotebook];
        }
    }
    
    return cell;
}

#pragma mark - TableView Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[Mixpanel sharedInstance] track:@"点击笔记本列表"];
    
    ENoteBookDO *notebook = mutNotebooks_[indexPath.section];
    if (notebook.stack) {
        NSArray *subNotebooks = [notebooks_ objectForKey:notebook.stack];
        ENoteBookDO *subNotebook = subNotebooks[indexPath.row];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EAllNotesViewController *allNotebookViewController = [story instantiateViewControllerWithIdentifier:@"EAllNotesViewController"];
        allNotebookViewController.guid = subNotebook.guid;
        allNotebookViewController.notebookName = subNotebook.name;
        [self.navigationController pushViewController:allNotebookViewController animated:YES];
    }
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
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Eleye %@ %@", APP_VERSION, LOCALSTRING(@"Feedback")]];
        NSString *body = [NSString stringWithFormat:@"\n\n\n\n\n\n%@ iOS %@ \n APP version %@ Build %@", [EUtility platformString], [UIDevice currentDevice].systemVersion, APP_VERSION, APP_BUILD_VERSION];
        [mail setMessageBody:body isHTML:NO];
        [mail setToRecipients:@[EMAIL]];
        
        [self presentViewController:mail animated:YES completion:nil];
    }
    else
    {
        [EUtility showAutoHintTips:LOCALSTRING(@"Your device cannot send email!")];
    }
}

#pragma mark - UIAlertView Delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [USER_DEFAULT removeObjectForKey:HOSTNAME];
        [[ENSession sharedSession] unauthenticate];
        [EUtility clearDataBase];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ELoginViewController *launchViewController = [story instantiateViewControllerWithIdentifier:@"ELoginViewController"];
        [self.navigationController pushViewController:launchViewController animated:YES];
        NSMutableArray *mutViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [mutViewControllers removeObjectAtIndex:1];
        self.navigationController.viewControllers = mutViewControllers;
    }
}

#pragma mark - MFMail Delegate -

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

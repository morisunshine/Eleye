//
//  EAllNotesViewController.m
//  Eleye
//
//  Created by Sheldon on 15/4/20.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EAllNotesViewController.h"
#import <ENSDKAdvanced.h>
#import "ENoteCell.h"

@interface EAllNotesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *notes_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *notebookNameBtn;

@end

@implementation EAllNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notebookNameBtn setTitle:self.notebookName forState:UIControlStateNormal];
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
    //nil 时为获取所有笔记
    filter.notebookGuid = self.guid;
    //TODO 分页封装
    EDAMRelatedQuery *query = [[EDAMRelatedQuery alloc] init];
    query.filter = filter;
    
    [client findNotesWithFilter:filter offset:0 maxNotes:10 success:^(EDAMNoteList *list) {
        notes_ = list.notes;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"获取失败");
        }
    }];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end

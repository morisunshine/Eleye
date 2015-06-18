
//
//  ENoteUpdateManager.m
//  Eleye
//
//  Created by sheldon on 15/5/25.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteUpdateManager.h"
#import "ENoteDAO.h"

@interface ENoteUpdateManager ()

@property (nonatomic, retain) NSMutableArray *updateTasks;

@end

@implementation ENoteUpdateManager

SINGLETON_CLASS(ENoteUpdateManager)

- (NSMutableArray *)updateTasks
{
    if (!_updateTasks) {
        _updateTasks = [[NSMutableArray alloc] init];
    }
    
    return _updateTasks;
}

#pragma mark - Public Methods -

- (void)checkUnUploadNotes
{
    dispatch_async(dispatch_queue_create("com.duotin.update.note", DISPATCH_QUEUE_SERIAL), ^{
        [self readNeedUploadedNotes];
        [self startUpload];
    });
}

- (void)addUploadNoteWithGuid:(NSString *)guid
{
    dispatch_async(dispatch_queue_create("com.duotin.update.note", DISPATCH_QUEUE_SERIAL), ^{
        EDAMNote *note = [[ENoteDAO sharedENoteDAO] noteWithGuid:guid];
        [self.updateTasks addObject:note];
        [self startUpload];
    });
}

#pragma mark - Private Methods -

- (void)readNeedUploadedNotes
{
    NSString *hostName = [USER_DEFAULT objectForKey:HOSTNAME];
    NSString *path = [APP_DOCUMENT stringByAppendingFormat:@"/%@/%@/%@", hostName, @([ENSession sharedSession].userID), WAITUPLOADFILE];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    for (NSString *guid in dic.allKeys) {
        NSNumber *updateTime = [dic objectForKey:guid];
        EDAMNote *note = [[ENoteDAO sharedENoteDAO] noteWithGuid:guid];
        if (note.deleted) {
            [EUtility removeValueWithKey:guid fileName:WAITUPLOADFILE];
        } else if ([updateTime integerValue] <= [note.updated integerValue]) {
            [EUtility removeValueWithKey:guid fileName:WAITUPLOADFILE];
        } else {
            [self.updateTasks addObject:note];
        }
    }
}

- (void)startUpload
{
    if (0 < self.updateTasks.count) {
        EDAMNote *note = [self.updateTasks firstObject];
        [self updateNoteWithNote:note];
    }
}

- (void)updateNoteWithNote:(EDAMNote *)note
{
    ENNoteStoreClient *client = [ENSession sharedSession].primaryNoteStore;
    
    NSString *htmlString = [EUtility noteHtmlFromLocalPathWithGuid:note.guid];
    NSString *topString = @"<?xml version=\"1.0\" encoding=\"UTF-8";
    NSRange range = [htmlString rangeOfString:topString];
    
    if (range.location != NSNotFound) {
        NSRange subRange = [htmlString rangeOfString:@"?>"];
        if (subRange.location != NSNotFound) {
            htmlString = [htmlString substringFromIndex:(subRange.location + 2)];
            NSString *newHtmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                                       "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                                       "%@", htmlString];
            htmlString = newHtmlString;
        }
    } else {
        htmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                      "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                      "%@", htmlString];
    }
    
    note.content = htmlString;
    
    [client updateNote:note success:^(EDAMNote *newNote) {
        NSLog(@"更新笔记成功 %@", newNote.title);
        
        [EUtility setSafeValue:newNote.updated key:note.guid fileName:LOCALUPDATEFILE];
        
        note.updated = newNote.updated;
        [[ENoteDAO sharedENoteDAO] saveBaseDO:note];
        
    } failure:^(NSError *error) {
        if (error) {
            NSLog(@"更新笔记失败%@", error);
        }
    }];
}

@end

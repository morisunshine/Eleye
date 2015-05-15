//
//  ENoteDAO.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteDAO.h"

@implementation ENoteDAO

SINGLETON_CLASS(ENoteDAO)

#pragma mark - Rewrite -

- (NSString *)tableName
{
    return @"table_note";
}

- (NSString *)createSqlString
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(_id INTEGER PRIMARY KEY AUTOINCREMENT, guid VARCHAR(200), notebookGuid VARCHAR(200), title VARCHAR(200), content VARCHAR(500), path VARCHAR(100), contentLength INTEGER, created INTEGER, updated INTEGER, deleted INTEGER, active INTEGER)", [self tableName]];
    
    return sql;
}

- (BOOL)saveBaseDO:(NSObject *)baseDO fmdb:(FMDatabase *)db
{
    ENoteDO *note = (ENoteDO *)baseDO;
    
    BOOL result = NO;
    
    NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where guid = ?", [self tableName]];
    FMResultSet *resultSet = [db executeQuery:selectSql, note.guid];
    
    if ([resultSet next]) {
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set notebookGuid = ?, title = ?, content = ?, path = ?, contentLength = ?, created = ?, updated = ?, deleted = ?, active = ? where guid = ?", [self tableName]];
        result = [db executeUpdate:updateSql, note.notebookGuid, note.title, note.content, note.path, note.contentLength, note.created, note.updated, note.deleted, note.active, note.guid];
        
        if (!result) {
            NSLog(@"error update %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    } else {
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(guid, notebookGuid, title, content, path, contentLength, created, updated, deleted, active) values(?,?,?,?,?,?,?,?,?,?)", [self tableName]];
        result = [db executeUpdate:insertSql, note.guid, note.notebookGuid, note.title, note.content, note.path, note.contentLength, note.created, note.updated, note.deleted, note.active];
        if (!result) {
            NSLog(@"error insert %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    }
    
    return result;
}

#pragma mark - Public Methods -

- (NSArray *)notesWithNotebookGuid:(NSString *)notebookGuid
{
    NSString *sql;
    
    if (notebookGuid == nil) {
        sql = [NSString stringWithFormat:@"select * from %@", [self tableName]];
    } else {
        sql = [NSString stringWithFormat:@"select * from %@ where notebookGuid = ?", [self tableName]];
    }
    
    __block NSMutableArray *mutNotes = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, notebookGuid];
        
        while ([resultSet next]) {
            ENoteDO *note = [self noteFromResultSet:resultSet];
            [mutNotes addObject:note];
        }
        
        [resultSet close];
    }];
    
    return mutNotes;
}

- (BOOL)deleteAllNotes
{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@", [self tableName]];
    
    __block BOOL result = NO;
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db executeUpdate:deleteSql];
        
        if (!result) {
            NSLog(@"error delete %@ error:%@", [self tableName], [db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (BOOL)deleteNoteWithGuid:(NSString *)guid
{  
    __block BOOL result = NO;
    
    if (guid) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where guid = \"%@\"", [self tableName], guid];
        
        [dbQueue inDatabase:^(FMDatabase *db) {
            
            result = [db executeUpdate:deleteSql];
            
            if (!result) {
                NSLog(@"error delete %@ error:%@", [self tableName], [db lastErrorMessage]);
            }
        }];
    }
    
    return result;
}

#pragma mark - Private Methods -

- (ENoteDO *)noteFromResultSet:(FMResultSet *)resultSet
{
    ENoteDO *note = [[ENoteDO alloc] init];
    note.guid = [resultSet stringForColumn:@"guid"];
    note.notebookGuid = [resultSet stringForColumn:@"notebookGuid"];
    note.title = [resultSet stringForColumn:@"title"];
    note.content = [resultSet stringForColumn:@"content"];
    note.contentLength = @([resultSet intForColumn:@"contentLength"]);
    note.created = @([resultSet intForColumn:@"created"]);
    note.updated = @([resultSet intForColumn:@"updated"]);
    note.deleted = @([resultSet intForColumn:@"deleted"]);
    note.active = @([resultSet intForColumn:@"active"]);
    note.path = [resultSet stringForColumn:@"path"];
    
    return note;
}

@end

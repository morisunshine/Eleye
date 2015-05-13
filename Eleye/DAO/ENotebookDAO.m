//
//  ENotebookDAO.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENotebookDAO.h"

@implementation ENotebookDAO

SINGLETON_CLASS(ENotebookDAO)

#pragma mark - Rewrite -

- (NSString *)tableName
{
    return @"table_notebook";
}

- (NSString *)createSqlString
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(_id INTEGER PRIMARY KEY AUTOINCREMENT, guid VARCHAR(200), name VARCHAR(200), count INTEGER, published INTEGER, stack VARCHAR(200), serviceCreated INTEGER, serviceUpdated INTEGER)", [self tableName]];
    
    return sql;
}

- (BOOL)saveBaseDO:(NSObject *)baseDO fmdb:(FMDatabase *)db
{
    ENoteBookDO *notebook = (ENoteBookDO *)baseDO;
    
    BOOL result = NO;
    
    NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where guid = ?", [self tableName]];
    FMResultSet *resultSet = [db executeQuery:selectSql, notebook.guid];
    
    if ([resultSet next]) {
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set name = ?, count = ?, published = ?, stack = ?, serviceCreated = ?, serviceUpdated = ? where guid = ?", [self tableName]];
        result = [db executeUpdate:updateSql, notebook.name, notebook.count, notebook.publishing, notebook.stack, notebook.serviceCreated, notebook.serviceUpdated, notebook.guid];
        
        if (!result) {
            NSLog(@"error update %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    } else {
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(guid, name, count, published, stack, serviceCreated, serviceUpdated) values(?,?,?,?,?,?,?)", [self tableName]];
        result = [db executeUpdate:insertSql, notebook.guid, notebook.name, notebook.count, notebook.publishing, notebook.stack, notebook.serviceCreated, notebook.serviceUpdated];
        if (!result) {
            NSLog(@"error insert %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    }
    
    return result;
}

#pragma mark - Public Methods -

- (NSArray *)notebooks
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@", [self tableName]];
    
    __block NSMutableArray *mutNotebooks = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while ([resultSet next]) {
            ENoteBookDO *notebook = [self notebookFromResultSet:resultSet];
            [mutNotebooks addObject:notebook];
        }
        
        [resultSet close];
    }];
    
    return mutNotebooks;
}

- (BOOL)deleteAllNoteBooks
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
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where guid = ?", [self tableName]];
    
    __block BOOL result = NO;
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db executeUpdate:deleteSql, guid];
        
        if (!result) {
            NSLog(@"error delete %@ error:%@", [self tableName], [db lastErrorMessage]);
        }
    }];
    
    return result;
}

#pragma mark - Private Methods -

- (ENoteBookDO *)notebookFromResultSet:(FMResultSet *)resultSet
{
    ENoteBookDO *notebook = [[ENoteBookDO alloc] init];
    notebook.guid = [resultSet stringForColumn:@"guid"];
    notebook.name = [resultSet stringForColumn:@"name"];
    notebook.published = @([resultSet intForColumn:@"published"]);
    notebook.stack = [resultSet stringForColumn:@"stack"];
    notebook.count = @([resultSet intForColumn:@"count"]);
    notebook.serviceCreated = @([resultSet intForColumn:@"serviceCreated"]);
    notebook.serviceUpdated = @([resultSet intForColumn:@"serviceUpdated"]);
    
    return notebook;
}

@end

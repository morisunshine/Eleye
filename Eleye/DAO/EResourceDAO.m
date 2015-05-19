//
//  EResourceDAO.m
//  Eleye
//
//  Created by sheldon on 15/5/19.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EResourceDAO.h"
#import "EResourceDO.h"

@implementation EResourceDAO

SINGLETON_CLASS(EResourceDAO)

#pragma mark - Rewrite -

- (NSString *)tableName
{
    return @"table_resource";
}

- (NSString *)createSqlString
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(_id INTEGER PRIMARY KEY AUTOINCREMENT, guid VARCHAR(200), noteGuid VARCHAR(200), width INTEGER, height INTEGER, data BINARY, mimeType VARCHAR(100), fileName VARCHAR(100))", [self tableName]];
    
    return sql;
}

- (BOOL)saveBaseDO:(NSObject *)baseDO fmdb:(FMDatabase *)db
{
    EResourceDO *resource = (EResourceDO *)baseDO;
    
    BOOL result = NO;
    
    NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where guid = ?", [self tableName]];
    FMResultSet *resultSet = [db executeQuery:selectSql, resource.guid];
    
    if ([resultSet next]) {
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set guid = ?, noteGuid = ?, width = ?, height = ?, data = ?, mimeType = ?, fileName = ? where guid = ?", [self tableName]];
        result = [db executeUpdate:updateSql, resource.guid, resource.noteGuid, resource.width, resource.height, resource.data, resource.mimeType, resource.fileName, resource.guid];
        
        if (!result) {
            NSLog(@"error update %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    } else {
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(guid, noteGuid, width, height, data, mimeType, fileName) values(?,?,?,?,?,?,?)", [self tableName]];
        result = [db executeUpdate:insertSql, resource.guid, resource.noteGuid, resource.width, resource.height, resource.data, resource.mimeType, resource.fileName];
        if (!result) {
            NSLog(@"error insert %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    }
    
    return result;
}

#pragma mark - Public Methods -

- (BOOL)deleteResourcesWithNoteGuid:(NSString *)noteGuid
{
    __block BOOL result = NO;
    
    if (noteGuid) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where noteGuid = \"%@\"", [self tableName], noteGuid];
        
        [dbQueue inDatabase:^(FMDatabase *db) {
            
            result = [db executeUpdate:deleteSql];
            
            if (!result) {
                NSLog(@"error delete %@ error:%@", [self tableName], [db lastErrorMessage]);
            }
        }];
    }
    
    return result;
}

- (NSArray *)resourcesWithNoteGuid:(NSString *)noteGuid
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where noteGuid = ?", [self tableName]];
    
    __block NSMutableArray *mutResources = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, noteGuid];
        
        while ([resultSet next]) {
            EResourceDO *resource = [self resourceFromResultSet:resultSet];
            [mutResources addObject:resource];
        }
        
        [resultSet close];
    }];
    
    return mutResources;
}

#pragma mark - Private Methods -

- (EResourceDO *)resourceFromResultSet:(FMResultSet *)resultSet
{
    EResourceDO *resource = [[EResourceDO alloc] init];
    
    resource.guid = [resultSet stringForColumn:@"guid"];
    resource.noteGuid = [resultSet stringForColumn:@"noteGuid"];
    resource.width = @([resultSet intForColumn:@"width"]);
    resource.height = @([resultSet intForColumn:@"height"]);
    resource.data = [resultSet dataForColumn:@"data"];
    resource.mimeType = [resultSet stringForColumn:@"mimeType"];
    resource.fileName = [resultSet stringForColumn:@"fileName"];
    
    return resource;
}

@end

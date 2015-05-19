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
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(_id INTEGER PRIMARY KEY AUTOINCREMENT, guid VARCHAR(200), noteGuid VARCHAR(200), width INTEGER, height INTEGER, data BINARY, mimeType VARCHAR(100), fileName VARCHAR(100)", [self tableName]];
    
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

@end

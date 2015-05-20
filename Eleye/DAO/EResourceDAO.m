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
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(_id INTEGER PRIMARY KEY AUTOINCREMENT, guid VARCHAR(200), note_guid VARCHAR(200), edam_attributes BINARY, source_url VARCHAR(200), data_hash BINARY, data BINARY, mime_type VARCHAR(100), file_name VARCHAR(100))", [self tableName]];
    
    return sql;
}

- (BOOL)saveBaseDO:(NSObject *)baseDO fmdb:(FMDatabase *)db
{
    EResourceDO *resource = (EResourceDO *)baseDO;
    
    BOOL result = NO;
    
    NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where guid = ?", [self tableName]];
    FMResultSet *resultSet = [db executeQuery:selectSql, resource.resource.guid];
    
    if ([resultSet next]) {
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set guid = ?, note_guid = ?, edam_attributes = ?, source_url = ?, data_hash = ?, data = ?, mime_type = ?, file_name = ? where guid = ?", [self tableName]];
        result = [db executeUpdate:updateSql, resource.resource.guid, resource.noteGuid, [self dataFromDic:resource.resource.edamAttributes], resource.resource.sourceUrl, resource.resource.dataHash, resource.resource.data, resource.resource.mimeType, resource.resource.filename, resource.resource.guid];
        
        if (!result) {
            NSLog(@"error update %@ error : %@", [self tableName], [db lastErrorMessage]);
        }
    } else {
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(guid, note_guid, edam_attributes, source_url, data_hash, data, mime_type, file_name) values(?,?,?,?,?,?,?,?)", [self tableName]];
        result = [db executeUpdate:insertSql, resource.resource.guid, resource.noteGuid, [self dataFromDic:resource.resource.edamAttributes], resource.resource.sourceUrl, resource.resource.dataHash, resource.resource.data, resource.resource.mimeType, resource.resource.filename];
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
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where note_guid = \"%@\"", [self tableName], noteGuid];
        
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
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where note_guid = ?", [self tableName]];
    
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
    ENResource *newResource = [[ENResource alloc] init];
    newResource.edamAttributes = [self dicFromData:[resultSet dataForColumn:@"edam_attributes"]];
    newResource.data = [resultSet dataForColumn:@"data"];
    newResource.mimeType = [resultSet stringForColumn:@"mime_type"];
    newResource.filename = [resultSet stringForColumn:@"file_name"];
    newResource.sourceUrl = [resultSet stringForColumn:@"source_url"];
    EResourceDO *resource = [[EResourceDO alloc] init];
    resource.noteGuid = [resultSet stringForColumn:@"note_guid"];
    resource.resource = newResource;
    
    return resource;
}

- (NSData *)dataFromDic:(NSDictionary *)dic
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    return data;
}

- (NSDictionary *)dicFromData:(NSData *)data
{
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return dic;
}

@end

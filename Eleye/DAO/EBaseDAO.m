//
//  EBaseDAO.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EBaseDAO.h"
#import "EDBManager.h"
#import <FMDatabaseAdditions.h>

@implementation EBaseDAO

- (id)init
{
    self = [super init];
    
    if (self) {
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    }
    
    [self createFMDatabase];
    [self createTable];
    
    return self;
}

- (BOOL)createFMDatabase
{
    if (dbQueue) {
        return YES;
    }
    
    dbQueue = [EDBManager sharedEDBManager].dbQueue;
    if (!dbQueue) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)dropTableWithTableName:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"drop table if exists %@", tableName];
    __block BOOL res = YES;
    [dbQueue inDatabase:^(FMDatabase *db) {
        res = [db executeUpdate:sql];
        NSAssert2(res, @"drop %@ failed: %@", tableName, [db lastErrorMessage]);
    }];
    
    return res;
}

- (NSString *)createSqlString
{
    return @"createSqlString";
}

- (BOOL)createTable
{
    __block BOOL result;
    [dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:[self createSqlString]];
        if (result) {
            NSLog(@"create data %@ success", [self tableName]);
        } else {
            NSLog(@"create table  %@ error:%@",[self tableName],[db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (NSString *)tableName
{
    return @"tableName";
}

- (BOOL)saveBaseDO:(NSObject *)baseDO
{
    __block BOOL result;
    [dbQueue inDatabase:^(FMDatabase *db) {
        result = [self saveBaseDO:baseDO fmdb:db];
        if (!result) {
            NSLog(@"error insert  %@ error:%@",[self tableName],[db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (void)saveItems:(NSArray *)baseDOs
{
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSObject *baseDO in baseDOs) {
            [self saveBaseDO:baseDO fmdb:db];
        }
    }];
}

- (BOOL)saveBaseDO:(NSObject *)baseDO fmdb:(FMDatabase *)db
{
    return YES;
}

- (BOOL)clearEmptyData
{   
    return YES;
}

- (void)clearFMDatabase
{
    dbQueue = nil;
}

- (void)renewFmDataBase
{
    [self createFMDatabase];
    [self createTable];
}

@end

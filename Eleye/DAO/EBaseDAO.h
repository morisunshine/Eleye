//
//  EBaseDAO.h
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>

@class FMDatabase, FMDatabaseQueue;

@interface EBaseDAO : NSObject
{
    FMDatabaseQueue *dbQueue;
}
//清除数据库
- (void)clearFMDatabase;
//重置数据库
- (void)renewFmDataBase;
//删除数据表
- (BOOL)dropTableWithTableName:(NSString *)tableName;
//创建数据表
- (BOOL)createTable;
//插入单个数据到数据表
- (BOOL)saveBaseDO:(NSObject *)baseDO fmdb:(FMDatabase *)db;
//插入多个数据到数据表
- (void)saveItems:(NSArray *)baseDOs;
//插入单个数据到数据表
- (BOOL)saveBaseDO:(NSObject *)baseDO;
//表名
- (NSString *)tableName;
//创建表的sql语句
- (NSString *)createSqlString;
//清除空数据
- (BOOL)clearEmptyData;

@end

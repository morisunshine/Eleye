//
//  EDBManager.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EDBManager.h"
#import <FMDatabaseQueue.h>

static NSString *kPath = @"Eleye.sqlite";

@implementation EDBManager

SINGLETON_CLASS(EDBManager)

- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = paths[0];
    docDir = [docDir stringByAppendingPathComponent:kPath];
    
    NSLog(@"sqlit path: %@", docDir);
    
    return docDir;
}

- (id)init
{
    if (self = [super init]) {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
    }
    
    return self;
}

@end

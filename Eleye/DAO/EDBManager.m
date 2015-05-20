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
    NSString *hostName = [USER_DEFAULT objectForKey:HOSTNAME];
    NSString *path = [APP_DOCUMENT stringByAppendingFormat:@"/%@/%@", hostName, @([ENSession sharedSession].userID)];
    if ([EUtility createFloderWithPath:path]) {
        path = [path stringByAppendingPathComponent:kPath];
    }
    NSLog(@"sqlit path: %@", path);
    
    return path;
}

- (id)init
{
    if (self = [super init]) {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
    }
    
    return self;
}

- (void)renewQueue
{
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
}

@end

//
//  EDBManager.h
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;

@interface EDBManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

+ (instancetype)sharedEDBManager;

- (void)renewQueue;

@end

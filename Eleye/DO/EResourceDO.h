//
//  EResource.h
//  Eleye
//
//  Created by sheldon on 15/5/19.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ENResource;

@interface EResourceDO : NSObject

@property (nonatomic, strong) NSString *noteGuid;
@property (nonatomic, strong) ENResource *resource;

@end

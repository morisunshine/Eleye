//
//  EResource.h
//  Eleye
//
//  Created by sheldon on 15/5/19.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EResourceDO : NSObject

@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *noteGuid;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *fileName;

@end

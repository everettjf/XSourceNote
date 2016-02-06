//
//  XSourceNote.h
//  XSourceNote
//
//  Created by everettjf on 16/2/6.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <AppKit/AppKit.h>

@class XSourceNote;

static XSourceNote *sharedPlugin;

@interface XSourceNote : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end
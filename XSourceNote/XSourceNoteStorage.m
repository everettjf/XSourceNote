//
//  XSourceNoteStorage.m
//  XSourceNote
//
//  Created by everettjf on 16/3/1.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteStorage.h"
#import "XSourceNoteUtil.h"

static NSString * const kStoreKeyProjectUniqueAddress = @"ProjectUniqueAddress";

@interface XSourceNoteStorage ()
{
    NSURL *_notePath;
    BOOL _dbReady;
}

@end

@implementation XSourceNoteStorage

+ (XSourceNoteStorage *)sharedStorage{
    static XSourceNoteStorage *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         inst = [[XSourceNoteStorage alloc]init];
    });
    return inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self ensureDB];
    }
    return self;
}

- (NSURL *)notePath{
    if(_notePath) return _notePath;
    
    NSString *workspaceFilePath = [XSourceNoteUtil currentWorkspaceFilePath];
    if(workspaceFilePath == nil)
        return nil;
    
    NSString *settingFileName = [NSString stringWithFormat:@"%@-%lu.xsnote",
                                 [workspaceFilePath lastPathComponent],
                                 [workspaceFilePath hash]
                                 ];
    
    NSString *noteUrlString =[[XSourceNoteUtil notesDirectory] stringByAppendingPathComponent:settingFileName];
    _notePath = [NSURL URLWithString:noteUrlString];
    NSLog(@"note path = %@", _notePath);
    return _notePath;
}

- (BOOL)ensureDB{
    if(_dbReady)return YES;
    
    if(!self.notePath)return NO;
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:self.notePath];
    return YES;
}

@end

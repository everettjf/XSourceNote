//
//  XSourceNoteStorage.h
//  XSourceNote
//
//  Created by everettjf on 16/3/1.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XSourceNoteModel.h"
#import "XSNote.h"

@interface XSourceNoteStorage : NSObject
@property (strong,readonly) NSURL *notePath;

+ (XSourceNoteStorage*)sharedStorage;
- (BOOL)ensureDB;
- (BOOL)isValid;

@property (strong) NSString *rootPath;

@property (strong) NSString *projectName;
@property (strong) NSString *projectSite;
@property (strong) NSString *projectRepo;
@property (strong) NSString *projectRevision;
@property (strong) NSString *projectDescription;

@property (strong) NSString *projectNote;
@property (strong) NSString *projectSummarize;

@property (strong) NSString *filePrefix;

// line note
- (void)addLineNote:(XSourceNoteLineEntity*)note;
- (XSNote*)fetchLineNote:(NSString*)uniqueID;
- (NSArray*)fetchAllLineNotes;
- (void)removeLineNote:(NSString *)uniqueID;

- (void)updateLineNote:(NSString *)uniqueID content:(NSString*)content;

@end

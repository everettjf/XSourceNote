//
//  XSourceNoteStorage.h
//  XSourceNote
//
//  Created by everettjf on 16/3/1.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagicalRecord.h"
#import "XSourceNoteModel.h"
#import "Note.h"

@interface XSourceNoteStorage : NSObject
@property (strong,readonly) NSURL *notePath;

+ (XSourceNoteStorage*)sharedStorage;
- (BOOL)ensureDB;

@property (strong) NSString *projectUniqueAddress;
@property (strong) NSString *projectName;
@property (strong) NSString *projectSite;
@property (strong) NSString *projectDescription;
@property (strong) NSString *projectNote;
@property (strong) NSString *projectSummarize;

// line note
- (void)addLineNote:(XSourceNoteIndex*)index;
- (Note*)fetchLineNote:(XSourceNoteIndex*)index;
- (NSArray*)fetchAllLineNotes;
- (void)removeLineNote:(XSourceNoteIndex*)index;

- (void)updateLineNote:(NSString *)uniqueID content:(NSString*)content;
- (NSString*)readLineNote:(NSString *)uniqueID;

@end

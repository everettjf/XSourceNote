//
//  XSourceNoteModel.h
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XSourceNoteEntity : NSObject
@property (copy) NSString *uniqueID;
@property (copy) NSString *source;
@property (assign) NSUInteger begin;
@property (assign) NSUInteger end;
@property (copy) NSString *content;

-(NSString*) title;
@end

extern NSString * const XSourceNoteModelLineNotesChanged;

@interface XSourceNoteIndex : NSObject
@property (strong) NSString *source;
@property (assign) NSUInteger begin;
@property (assign) NSUInteger end;

+ (XSourceNoteIndex*)index:(NSString*)source begin:(NSUInteger)begin end:(NSUInteger)end;

- (NSString*)uniqueID;

@end

typedef void (^XSourceNoteModelFetchAllNotesBlock)(NSArray *notes);

@interface XSourceNoteModel : NSObject

+(XSourceNoteModel *)sharedModel;

- (void)addLineNote:(XSourceNoteIndex*)index;
- (void)removeLineNote:(XSourceNoteEntity *)index;
- (BOOL)hasLineMark:(NSString*)source line:(NSUInteger)line;
- (void)fetchAllNotes:(XSourceNoteModelFetchAllNotesBlock)completion;
- (void)ensureInit;

@end



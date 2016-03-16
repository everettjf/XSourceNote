//
//  XSourceNoteModel.m
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "XSourceNoteModel.h"
#import "XSourceNoteUtil.h"
#import "XSourceNoteStorage.h"

NSString * const XSourceNoteModelLineNotesChanged = @"XSourceNoteModelLineNotesChanged";

static inline NSString* XSourceNote_HashLine(NSString *source,NSUInteger line){
    return [NSString stringWithFormat:@"%lu/%lu",line,[source hash]];
}

@interface XSourceNoteModel ()

// for fast check
@property (nonatomic,strong) NSMutableSet<NSString*> *markset;

@end

@implementation XSourceNoteModel

+(XSourceNoteModel *)sharedModel{
    static XSourceNoteModel *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[XSourceNoteModel alloc]init];
    });
    return inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _markset = [NSMutableSet new];
    }
    return self;
}

- (BOOL)hasLineMark:(NSString *)source line:(NSUInteger)line{
    BOOL has = NO;
    @synchronized(_markset) {
        has = [_markset containsObject:XSourceNote_HashLine(source, line)];
    }
    return has;
}

- (void)addLineNote:(XSourceNoteLineEntity *)note{
    
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    [st addLineNote:note];
    
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        @synchronized(_markset) {
            for(NSUInteger idx = note.begin; idx <= note.end; ++idx){
                [_markset addObject:XSourceNote_HashLine(note.source, idx)];
            }
        }
        
        [self _notifyLineNotesChanged];
    });
}

- (void)removeLineNote:(XSourceNoteLineEntity *)note{
    [[XSourceNoteStorage sharedStorage]removeLineNote:note.uniqueID];
    
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        @synchronized(_markset) {
            for(NSUInteger idx = note.begin; idx <= note.end; ++idx){
                [_markset removeObject:XSourceNote_HashLine(note.source, idx)];
            }
        }
        
        [self _notifyLineNotesChanged];
    });
}

- (void)fetchAllNotes:(XSourceNoteModelFetchAllNotesBlock)completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *notes = [[XSourceNoteStorage sharedStorage]fetchAllLineNotes];
        NSMutableArray *entities = [NSMutableArray new];
        for (XSNote* note in notes) {
            XSourceNoteLineEntity *entity = [XSourceNoteLineEntity new];
            entity.uniqueID = note.uniqueID;
            entity.source = note.source;
            entity.begin = note.begin.unsignedIntegerValue;
            entity.end = note.end.unsignedIntegerValue;
            if(note.content)
                entity.content = [[NSString alloc]initWithString:note.content];
            else
                entity.content = @"";
            entity.code = note.code;
            [entities addObject:entity];
        }
        
        // rehash the map
        @synchronized(_markset) {
            for (XSourceNoteLineEntity *note in entities) {
                for(NSUInteger idx = note.begin;
                    idx <= note.end;
                    ++idx){
                    [_markset addObject:XSourceNote_HashLine(note.source, idx)];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion?:completion(entities);
        });
    });
}

- (void)_notifyLineNotesChanged{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:XSourceNoteModelLineNotesChanged object:nil];
    });
}

- (void)ensureInit{
    [[XSourceNoteStorage sharedStorage]ensureDB];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self fetchAllNotes:nil];
    });
}

@end

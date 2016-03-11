//
//  XSourceNoteModel.h
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XSourceNoteDataset.h"


extern NSString * const XSourceNoteModelLineNotesChanged;


typedef void (^XSourceNoteModelFetchAllNotesBlock)(NSArray *notes);

@interface XSourceNoteModel : NSObject

+(XSourceNoteModel *)sharedModel;

- (void)addLineNote:(XSourceNoteLineEntity*)note;
- (void)removeLineNote:(XSourceNoteLineEntity *)note;
- (BOOL)hasLineMark:(NSString*)source line:(NSUInteger)line;
- (void)fetchAllNotes:(XSourceNoteModelFetchAllNotesBlock)completion;
- (void)ensureInit;

@end



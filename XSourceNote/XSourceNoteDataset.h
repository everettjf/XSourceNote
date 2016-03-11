//
//  XSourceNoteDataset.h
//  XSourceNote
//
//  Created by everettjf on 16/3/10.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, XSourceNoteEntityType) {
    XSourceNoteEntityTypeBasicInformation = 0,
    XSourceNoteEntityTypeProjectNote = 1,
    XSourceNoteEntityTypeLineNote = 2,
    XSourceNoteEntityTypeSummarize = 3,
    XSourceNoteEntityTypeTool = 4,
};

@interface XSourceNoteEntityObject : NSObject

@property (assign) XSourceNoteEntityType type;
-(NSString*) title;

@end

@interface XSourceNoteLineEntity : XSourceNoteEntityObject
@property (copy) NSString *uniqueID;
@property (copy) NSString *source;
@property (copy) NSString *localPath;
@property (assign) NSUInteger begin;
@property (assign) NSUInteger end;
@property (copy) NSString *content;
@property (copy) NSString *code;

@end

@interface XSourceNoteBasicInformationEntity : XSourceNoteEntityObject
@end

@interface XSourceNoteProjectNoteEntity : XSourceNoteEntityObject
@end

@interface XSourceNoteProjectSummarizeEntity : XSourceNoteEntityObject
@end

@interface XSourceNoteProjectToolEntity : XSourceNoteEntityObject
@end

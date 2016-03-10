//
//  XSourceNoteDataset.m
//  XSourceNote
//
//  Created by everettjf on 16/3/10.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteDataset.h"


@implementation XSourceNoteEntityObject

- (NSString *)title{
    return @"empty";
}

@end

@implementation XSourceNoteLineEntity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = XSourceNoteEntityTypeLineNote;
    }
    return self;
}

- (NSString *)title{
    NSString *fileName = [self.source lastPathComponent];
    
    if(self.begin == self.end){
        return [NSString stringWithFormat:@"%@ [%@]", fileName, @(self.begin)];
    }
    return [NSString stringWithFormat:@"%@ [%@,%@]", fileName, @(self.begin),@(self.end)];
}
@end


@implementation XSourceNoteBasicInformationEntity : XSourceNoteEntityObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = XSourceNoteEntityTypeBasicInformation;
    }
    return self;
}

- (NSString *)title{
    return @"Basic Information";
}

@end

@implementation XSourceNoteProjectNoteEntity : XSourceNoteEntityObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = XSourceNoteEntityTypeProjectNote;
    }
    return self;
}

- (NSString *)title{
    return @"Project Note";
}

@end

@implementation  XSourceNoteProjectSummarizeEntity : XSourceNoteEntityObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = XSourceNoteEntityTypeSummarize;
    }
    return self;
}

- (NSString *)title{
    return @"Summarize";
}

@end

@implementation XSourceNoteProjectToolEntity : XSourceNoteEntityObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = XSourceNoteEntityTypeTool;
    }
    return self;
}

- (NSString *)title{
    return @"Tool";
}

@end

//
//  Note.m
//  XSourceNote
//
//  Created by everettjf on 16/2/29.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "Note.h"
#import "XSourceNoteModel.h"

@implementation Note

- (XSourceNoteIndex *)noteIndex{
    return [XSourceNoteIndex index:self.pathLocal
                             begin:self.lineNumberBegin.unsignedIntegerValue
                               end:self.lineNumberEnd.unsignedIntegerValue];
}

- (NSString *)title{
    NSString *fileName = [self.pathLocal lastPathComponent];
    
    if([self.lineNumberBegin isEqualToNumber:self.lineNumberEnd]){
        return [NSString stringWithFormat:@"%@ [%@]", fileName, self.lineNumberBegin];
    }
    return [NSString stringWithFormat:@"%@ [%@,%@]", fileName, self.lineNumberBegin,self.lineNumberEnd];
}

@end

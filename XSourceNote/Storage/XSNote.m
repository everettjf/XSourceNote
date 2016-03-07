//
//  XSNote.m
//  XSourceNote
//
//  Created by everettjf on 16/3/7.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSNote.h"
#import "XSourceNoteModel.h"

@implementation XSNote

// Insert code here to add functionality to your managed object subclass
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

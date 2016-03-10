//
//  XSourceNoteTableCellView.m
//  XSourceNote
//
//  Created by everettjf on 16/3/6.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteTableCellView.h"
#import "XSourceNoteModel.h"

@implementation XSourceNoteTableCellView

-(void)setNote:(XSourceNoteEntityObject *)note{
    _note = note;
    
    _titleField.stringValue = [note title];
    _contentField.stringValue = @"";
    
    if(_note.type == XSourceNoteEntityTypeLineNote){
        [self setLineNote:(id)note];
    }
}
- (void)setLineNote:(XSourceNoteLineEntity *)lineNote{
    NSString *content = lineNote.content;
    if(!content) content = @"";
    
    _contentField.stringValue = [content copy];
    
    _contentField.maximumNumberOfLines = 2;
    _contentField.editable = NO;
}

@end

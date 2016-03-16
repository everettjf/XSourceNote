//
//  XSourceNoteQuickNoteWindowController.m
//  XSourceNote
//
//  Created by everettjf on 16/3/15.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteQuickNoteWindowController.h"
#import "XSourceNoteDataset.h"
#import "XSourceNoteStorage.h"

@interface XSourceNoteQuickNoteWindowController ()
@property (weak) IBOutlet NSTextField *titleField;
@property (unsafe_unretained) IBOutlet NSTextView *noteView;

@end

@implementation XSourceNoteQuickNoteWindowController

- (instancetype)init
{
    return [self initWithWindowNibName:@"XSourceNoteQuickNoteWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.titleField.editable = NO;
}

- (void)refresh{
    if(!self.line)return;
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    
    // save current
    NSString *currentContent = [self.noteView.string copy];
    if(![currentContent isEqualToString:@""]){
        [st updateLineNote:self.line.uniqueID content:currentContent];
    }
    
    // load new
    self.titleField.stringValue = [self.line title];
    XSNote *newNote = [st fetchLineNote:self.line.uniqueID];
    if(newNote){
        NSString *newContent = newNote.content;
        if(newContent){
            self.noteView.string = newContent;
        }
    }
    
}

@end

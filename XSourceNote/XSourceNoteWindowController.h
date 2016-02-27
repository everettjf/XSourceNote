//
//  XSourceNoteWindowController.h
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XSourceNoteTableCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *titleField;
@property (weak) IBOutlet NSTextField *subtitleField;
@end

@interface XSourceNoteWindowController : NSWindowController

-(void)refreshBookmarks;

@end

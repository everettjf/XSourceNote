//
//  XSourceNoteQuickNoteWindowController.h
//  XSourceNote
//
//  Created by everettjf on 16/3/15.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XSourceNoteLineEntity;
@interface XSourceNoteQuickNoteWindowController : NSWindowController

@property (strong) XSourceNoteLineEntity *line;

- (void)saveCurrentContent;
- (void)refresh;

@end

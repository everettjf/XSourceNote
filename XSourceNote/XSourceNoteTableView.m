//
//  XSourceNoteTableView.m
//  XSourceNote
//
//  Created by everettjf on 16/3/5.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteTableView.h"

@implementation XSourceNoteTableView

- (void)keyDown:(NSEvent *)theEvent{
    NSString *chars = [theEvent characters];
    unichar key = [chars characterAtIndex:0];
    if(key == NSDeleteCharacter){
        NSLog(@"delete key event");
        if(self.deleteKeyAction){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.deleteKeyAction withObject:self];
#pragma clang diagnostic pop
        }
    }
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    
//    // Drawing code here.
//}
//
@end

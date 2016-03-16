//
//  DVTTextSidebarView+XSourceNote.m
//  XSourceNote
//
//  Created by everettjf on 10/31/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "DVTTextSidebarView+XSourceNote.h"
#import "JRSwizzle.h"
#import "IDEKit.h"
#import "XSourceNoteModel.h"
#import "XSourceNoteStorage.h"

@implementation DVTTextSidebarView (XSourceNote)

+(void)load{
    NSError *error = nil;
    [DVTTextSidebarView jr_swizzleMethod:@selector(_drawLineNumbersInSidebarRect:foldedIndexes:count:linesToInvert:linesToReplace:getParaRectBlock:)
                              withMethod:@selector(XSourceNote_drawLineNumbersInSidebarRect:foldedIndexes:count:linesToInvert:linesToReplace:getParaRectBlock:)
                                   error:& error];
    
}

- (void)XSourceNote_drawLineNumbersInSidebarRect:(CGRect)rect
                                 foldedIndexes:(NSUInteger *)indexes
                                         count:(NSUInteger)indexCount
                                 linesToInvert:(id)invert
                                linesToReplace:(id)replace
                              getParaRectBlock:(id)rectBlock{
    
    NSString *rootPath = [XSourceNoteStorage sharedStorage].rootPath;
    if(rootPath && ![rootPath isEqualToString:@""]){
        NSString *fileName = self.window.representedFilename;
        NSString *relativePath = [fileName stringByReplacingOccurrencesOfString:rootPath withString:@""];
        
        for(NSUInteger idx = 0; idx < indexCount; ++idx){
            NSUInteger line = indexes[idx];
            if([[XSourceNoteModel sharedModel]hasLineMark:relativePath line:line]){
                [self XSourceNote_drawNoteAtLine:line];
            }
        }
    }
    
    [self XSourceNote_drawLineNumbersInSidebarRect:rect foldedIndexes:indexes count:indexCount linesToInvert:invert linesToReplace:replace getParaRectBlock:rectBlock];
}

static inline NSRect NSRectRelativeTo(NSRect rect,NSPoint origin){
    return NSMakeRect(origin.x + rect.origin.x, origin.y + rect.origin.y,rect.size.width,rect.size.height);
}

-(void)XSourceNote_drawNoteAtLine:(NSUInteger)lineNumber{
    CGRect paragRect,lineRect;
    [self getParagraphRect:&paragRect firstLineRect:&lineRect forLineNumber:lineNumber];
    
    //// Color Declarations
    NSColor* color = [NSColor colorWithCalibratedRed: 0.389 green: 0.994 blue: 0.356 alpha: 1];
    //// Rectangle Drawing
    NSBezierPath* rectanglePath = [NSBezierPath bezierPathWithRect: NSRectRelativeTo(NSMakeRect(0, 0, 4, lineRect.size.height), lineRect.origin)];
    [color setFill];
    [rectanglePath fill];
}

@end

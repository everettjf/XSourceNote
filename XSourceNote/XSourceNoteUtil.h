//
//  XcodeUtil.h
//  XSourceNote
//
//  Created by everettjf on 9/29/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DVTKit.h"
#import "IDEKit.h"
#import "IDESourceEditor.h"

// Helper globals
@interface XSourceNoteGlobal : NSObject
+(XSourceNoteGlobal*)shared;
@property (nonatomic,weak) IDEWorkspaceWindowController *mainWorkspaceWindowController;
@end


@interface XSourceNoteUtil : NSObject
+ (IDEWorkspaceDocument*)currentWorkspaceDocument;
+ (IDEWorkspaceTabController*)tabController;
+ (IDESourceCodeEditor*)currentEditor;
+ (IDESourceCodeDocument*)currentSourceCodeDocument;
+ (IDEWorkspace*)currentIDEWorkspace;
+ (IDEWorkspaceWindowController*)currentIDEWorkspaceWindowController;

// Helper
+ (NSUInteger)locationRangeForTextView:(DVTSourceTextView*)textView forLine:(NSUInteger)lineNumber;
+ (NSString*)currentWorkspaceFilePath;
//+ (BOOL)openSourceFile:(NSString*)sourceFilePath highlightLineNumber:(NSUInteger)lineNumber;
+ (BOOL)openSourceFile:(NSString*)sourceFilePath highlightLineNumber:(NSUInteger)lineNumber;

+ (NSString*)settingDirectory;

@end

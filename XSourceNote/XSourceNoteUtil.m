//
//  XcodeUtil.m
//  XSourceNote
//
//  Created by everettjf on 9/29/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "XSourceNoteUtil.h"
#import <objc/runtime.h>

@implementation XSourceNoteGlobal

+(XSourceNoteGlobal *)shared{
    static XSourceNoteGlobal *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[XSourceNoteGlobal alloc]init];
    });
    return inst;
}

@end

@implementation XSourceNoteUtil


+ (IDEWorkspaceTabController*)tabController
{
    NSWindowController* currentWindowController = [XSourceNoteUtil currentIDEWorkspaceWindowController];
    if ([currentWindowController
            isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController* workspaceController = (IDEWorkspaceWindowController*)currentWindowController;

        return workspaceController.activeWorkspaceTabController;
    }
    return nil;
}

+ (id)currentEditor
{
    NSWindowController* currentWindowController = [XSourceNoteUtil currentIDEWorkspaceWindowController];
    if ([currentWindowController
            isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController* workspaceController = (IDEWorkspaceWindowController*)currentWindowController;
        IDEEditorArea* editorArea = [workspaceController editorArea];
        IDEEditorContext* editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

+ (IDEWorkspace*)currentIDEWorkspace {
    return (IDEWorkspace*) [[XSourceNoteUtil currentIDEWorkspaceWindowController] valueForKey:@"_workspace"];
}

+ (IDEWorkspaceDocument*)currentWorkspaceDocument
{
    NSWindowController* currentWindowController = [XSourceNoteUtil currentIDEWorkspaceWindowController];
    id document = [currentWindowController document];
    if (currentWindowController &&
        [document isKindOfClass:NSClassFromString(@"IDEWorkspaceDocument")]) {
        return (IDEWorkspaceDocument*)document;
    }
    return nil;
}

+ (IDESourceCodeDocument*)currentSourceCodeDocument
{

    IDESourceCodeEditor* editor = [self currentEditor];

    if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return editor.sourceCodeDocument;
    }

    if ([editor
            isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        if ([[(IDESourceCodeComparisonEditor*)editor primaryDocument]
                isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            return (id)[(IDESourceCodeComparisonEditor*)editor primaryDocument];
        }
    }

    return nil;
}

+(NSString *)currentWorkspaceFilePath{
    IDEWorkspaceDocument *document = [XSourceNoteUtil currentWorkspaceDocument];
    if(nil == document)
        return nil;
    DVTFilePath *workspacefilePath = document.workspace.representingFilePath;
    return [[workspacefilePath.fileURL absoluteString] stringByRemovingPercentEncoding];
}

+ (void)highlightLine:(NSUInteger)lineNumber inTextView:(NSTextView*)textView
{
    --lineNumber;
    
    NSString* text = [textView string];

    NSRegularExpression* re =
        [NSRegularExpression regularExpressionWithPattern:@"\n"
                                                  options:0
                                                    error:nil];

    NSArray* result = [re matchesInString:text
                                  options:NSMatchingReportCompletion
                                    range:NSMakeRange(0, text.length)];

    if (result.count <= lineNumber) {
        return;
    }

    NSUInteger location = 0;
    NSTextCheckingResult* aim = result[lineNumber];
    location = aim.range.location;

    NSRange range = [text lineRangeForRange:NSMakeRange(location, 0)];

    [textView scrollRangeToVisible:range];

    [textView setSelectedRange:range];
}


+ (IDEWorkspaceWindowController*)currentIDEWorkspaceWindowController {
    if([XSourceNoteGlobal shared].mainWorkspaceWindowController == nil){
        [XSourceNoteGlobal shared].mainWorkspaceWindowController = (IDEWorkspaceWindowController *)[[NSApp mainWindow]windowController];
    }
    return [XSourceNoteGlobal shared].mainWorkspaceWindowController;
}

+ (void)jumpToFileURL:(NSURL *)fileURL {
    DVTDocumentLocation *documentLocation = [[DVTDocumentLocation alloc] initWithDocumentURL:fileURL timestamp:nil];
    IDEEditorOpenSpecifier *openSpecifier = [IDEEditorOpenSpecifier structureEditorOpenSpecifierForDocumentLocation:documentLocation inWorkspace:[XSourceNoteUtil currentIDEWorkspace]
    error:nil];
    [[XSourceNoteUtil currentIDEWorkspaceWindowController].editorArea.lastActiveEditorContext openEditorOpenSpecifier:openSpecifier];
}

+ (NSUInteger)locationRangeForTextView:(DVTSourceTextView*)textView forLine:(NSUInteger)lineNumber {
    DVTTextStorage *textStorage = (DVTTextStorage*)textView.textStorage;
    NSRange characterRange = [textStorage characterRangeForLineRange:NSMakeRange(lineNumber, 0)];
    return characterRange.location;
}

+(BOOL)openSourceFile:(NSString *)sourceFilePath highlightLineNumber:(NSUInteger)lineNumber{
    if(!sourceFilePath) return NO;
    IDESourceCodeDocument *document = [XSourceNoteUtil currentSourceCodeDocument];
    if(!document.fileURL)return NO;
    
    NSString *currentPath = document.fileURL.path;
    if(!currentPath)return NO;
    
    if(![sourceFilePath isEqualToString:currentPath]){
        [self jumpToFileURL:[NSURL fileURLWithPath:sourceFilePath]];
    }

    IDESourceCodeEditor *editor = [XSourceNoteUtil currentEditor];
    if (editor) {
        DVTSourceTextView* textView = editor.textView;
        
        NSUInteger lineLocation = [XSourceNoteUtil locationRangeForTextView:textView forLine:lineNumber-1];
        NSRange locationRange = NSMakeRange(lineLocation, 0);
        		
        [textView setSelectedRange:locationRange];
        [textView scrollRangeToVisible:locationRange];
        [textView showFindIndicatorForRange:locationRange];
    }
    return YES;
}

+ (NSString*)settingDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* settingDirectory = [(NSString*)[paths firstObject] stringByAppendingPathComponent:@"XSourceNote"];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if (![fileManger fileExistsAtPath:settingDirectory]) {
        [fileManger createDirectoryAtPath:settingDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return settingDirectory;
}
+ (NSString *)notesDirectory{
    NSString *settingDir = [XSourceNoteUtil settingDirectory];
    NSString *notesDir = [settingDir stringByAppendingPathComponent:@"Notes"];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if (![fileManger fileExistsAtPath:notesDir]) {
        [fileManger createDirectoryAtPath:notesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return notesDir;
}


@end

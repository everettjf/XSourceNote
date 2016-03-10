//
//  XSourceNote.m
//  XSourceNote
//
//  Created by everettjf on 16/2/6.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNote.h"
#import "XSourceNoteUtil.h"
#import "XSourceNoteModel.h"
#import "XSourceNoteWindowController.h"
#import "XSourceNoteDefaults.h"
#import "XSourceNoteStorage.h"

@interface XSourceNote()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) XSourceNoteWindowController *windowController;
@end

@implementation XSourceNote

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *mainMenu = [[menuItem submenu]addItemWithTitle:@"XSourceNote" action:nil keyEquivalent:@""];
        NSMenu *submenu = [[NSMenu alloc]init];
        mainMenu.submenu = submenu;
        
        {
            MASShortcut *shortcut = [XSourceNoteDefaults sharedDefaults].currentShortcutToggle;
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Note" action:@selector(toggleNote)
                                                             keyEquivalent:shortcut.keyCodeStringForKeyEquivalent];
            [actionMenuItem setKeyEquivalentModifierMask:shortcut.modifierFlags];
            [actionMenuItem setTarget:self];
            [[mainMenu submenu] addItem:actionMenuItem];
            
            [XSourceNoteDefaults sharedDefaults].toggleMenuItem = actionMenuItem;
        }
        {
            MASShortcut *shortcut = [XSourceNoteDefaults sharedDefaults].currentShortcutShow;
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show Notes" action:@selector(showNotes)
                                                             keyEquivalent:shortcut.keyCodeStringForKeyEquivalent];
            [actionMenuItem setKeyEquivalentModifierMask:shortcut.modifierFlags];
            [actionMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask];
            [actionMenuItem setTarget:self];
            [[mainMenu submenu] addItem:actionMenuItem];
            
            [XSourceNoteDefaults sharedDefaults].showMenuItem = actionMenuItem;
        }
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)toggleNote
{
    [[XSourceNoteModel sharedModel]ensureInit];
    
    IDESourceCodeEditor* editor = [XSourceNoteUtil currentEditor];
    if(!editor)return;
    if ([editor isKindOfClass:[IDEEditorEmpty class]]) return;
    
    NSTextView* textView = editor.textView;
    if (!textView)return;
    
    NSRange range = [textView.selectedRanges[0] rangeValue];
    NSUInteger startLineNumber = [[[textView string]substringToIndex:range.location]componentsSeparatedByString:@"\n"].count;
    NSUInteger endLineNumber = startLineNumber;
    if(range.length > 0){
        endLineNumber = [[[textView string]substringToIndex:range.location + range.length]componentsSeparatedByString:@"\n"].count;
    }
//    NSLog(@"range = (%@,%@) , startLine = %@, endLine = %@",
//          @(range.location), @(range.length), @(startLineNumber),@(endLineNumber));
    
    NSRange lineRange = [[textView string]lineRangeForRange:range];
//    NSLog(@"line range = (%@,%@)", @(range.location),@(range.length));
    NSString *codeOfLines = [[textView string]substringWithRange:lineRange];
//    NSLog(@"code below = \n%@", codeOfLines);
    
    // length of "file://" is 7
    NSString *sourcePath = [[editor.sourceCodeDocument.fileURL absoluteString] substringFromIndex:7];
    
    [[XSourceNoteModel sharedModel]addLineNote:[XSourceNoteIndex index:sourcePath begin:startLineNumber end:endLineNumber] code:codeOfLines];
    
    NSView *sidebar = [editor valueForKey:@"_sidebarView"];
    if(sidebar)[sidebar setNeedsDisplay:YES];
}

- (void)showNotes{
    [[XSourceNoteModel sharedModel]ensureInit];
    
    if(self.windowController.window.isVisible){
        [self.windowController.window close];
    }else{
        if(self.windowController == nil){
            // Remember the current IDE workspace window controller
            [XSourceNoteUtil currentIDEWorkspaceWindowController];
            
            self.windowController = [[XSourceNoteWindowController alloc]initWithWindowNibName:@"XSourceNoteWindowController"];
        }
        
        self.windowController.window.title = [[XSourceNoteUtil currentWorkspaceDocument].displayName stringByDeletingLastPathComponent];
        [self.windowController.window makeKeyAndOrderFront:nil];
    }
}


@end

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

@interface XSourceNote()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) XSourceNoteWindowController *windowController;
@property (nonatomic, assign) NSUInteger currentNoteIndex;
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
        
        // default to the first note (if have notes)
        self.currentNoteIndex = 0;
        
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
    [[XSourceNoteModel sharedModel]loadOnceNotes];
    
    IDESourceCodeEditor* editor = [XSourceNoteUtil currentEditor];
    if ([editor isKindOfClass:[IDEEditorEmpty class]]) {
        return;
    }
    NSTextView* textView = editor.textView;
    if (nil == textView)
        return;
    
    NSRange range = [textView.selectedRanges[0] rangeValue];
    NSUInteger startLineNumber = [[[textView string]substringToIndex:range.location]componentsSeparatedByString:@"\n"].count;
    NSUInteger endLineNumber = startLineNumber;
    if(range.length > 0){
        endLineNumber = [[[textView string]substringToIndex:range.location + range.length]componentsSeparatedByString:@"\n"].count;
    }
    NSLog(@"range = (%@,%@) , startLine = %@, endLine = %@",
          @(range.location), @(range.length), @(startLineNumber),@(endLineNumber));
    
    // length of "file://" is 7
    NSString *sourcePath = [[editor.sourceCodeDocument.fileURL absoluteString] substringFromIndex:7];
    
    XSourceNoteEntity *note = [[XSourceNoteEntity alloc]initWithSourcePath:sourcePath withLineNumber:startLineNumber];
    [[XSourceNoteModel sharedModel]toggleNote:note];
    
    [[XSourceNoteModel sharedModel]saveNotes];
    
    // point to the new added note
    self.currentNoteIndex = [XSourceNoteModel sharedModel].notes.count - 1;
    
    [[editor valueForKey:@"_sidebarView"]setNeedsDisplay:YES];
}

- (void)nextNote{
    [[XSourceNoteModel sharedModel]loadOnceNotes];
    
    XSourceNoteModel *model = [XSourceNoteModel sharedModel];
    if(model.notes.count == 0)
        return;
    NSUInteger nextIndex = self.currentNoteIndex + 1;
    if(nextIndex >= model.notes.count){
        // 如果超了就回到第一个
        nextIndex = 0;
    }
    
    XSourceNoteEntity *note = [model.notes objectAtIndex:nextIndex];
    [XSourceNoteUtil openSourceFile:note.sourcePath highlightLineNumber:note.lineNumber];
    self.currentNoteIndex = nextIndex;
}
- (void)previousNote{
    [[XSourceNoteModel sharedModel]loadOnceNotes];
    
    XSourceNoteModel *model = [XSourceNoteModel sharedModel];
    if(model.notes.count == 0)
        return;
    NSUInteger previousIndex;
    if(self.currentNoteIndex == 0){
        // 如果已经是第一个，则到最后一个
        previousIndex = model.notes.count - 1;
    }else{
        previousIndex = self.currentNoteIndex - 1;
    }
    if(previousIndex >= model.notes.count){
        previousIndex = model.notes.count - 1;
    }
    
    XSourceNoteEntity *note = [model.notes objectAtIndex:previousIndex];
    [XSourceNoteUtil openSourceFile:note.sourcePath highlightLineNumber:note.lineNumber];
    self.currentNoteIndex = previousIndex;
}
- (void)showNotes{
    [[XSourceNoteModel sharedModel]loadOnceNotes];
    
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
        [self.windowController refreshNotes];
    }
}


@end

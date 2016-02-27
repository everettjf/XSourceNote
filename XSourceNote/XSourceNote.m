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
@property (nonatomic, assign) NSUInteger currentBookmarkIndex;
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
        
        // default to the first bookmark (if have bookmarks)
        self.currentBookmarkIndex = 0;
        
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
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Toggle Bookmark" action:@selector(toggleBookmark)
                                                             keyEquivalent:shortcut.keyCodeStringForKeyEquivalent];
            [actionMenuItem setKeyEquivalentModifierMask:shortcut.modifierFlags];
            [actionMenuItem setTarget:self];
            [[mainMenu submenu] addItem:actionMenuItem];
            
            [XSourceNoteDefaults sharedDefaults].toggleMenuItem = actionMenuItem;
        }
        {
            MASShortcut *shortcut = [XSourceNoteDefaults sharedDefaults].currentShortcutNext;
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Next Bookmark" action:@selector(nextBookmark)
                                                             keyEquivalent:shortcut.keyCodeStringForKeyEquivalent];
            [actionMenuItem setKeyEquivalentModifierMask:shortcut.modifierFlags];
            [actionMenuItem setTarget:self];
            [[mainMenu submenu] addItem:actionMenuItem];
            
            [XSourceNoteDefaults sharedDefaults].nextMenuItem = actionMenuItem;
        }
        {
            MASShortcut *shortcut = [XSourceNoteDefaults sharedDefaults].currentShortcutPrev;
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Previous Bookmark" action:@selector(previousBookmark)
                                                             keyEquivalent:shortcut.keyCodeStringForKeyEquivalent];
            [actionMenuItem setKeyEquivalentModifierMask:shortcut.modifierFlags];
            [actionMenuItem setTarget:self];
            [[mainMenu submenu] addItem:actionMenuItem];
            
            [XSourceNoteDefaults sharedDefaults].prevMenuItem = actionMenuItem;
        }
        {
            MASShortcut *shortcut = [XSourceNoteDefaults sharedDefaults].currentShortcutShow;
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show Bookmarks" action:@selector(showBookmarks)
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

- (void)toggleBookmark
{
    [[XSourceNoteModel sharedModel]loadOnceBookmarks];
    
    IDESourceCodeEditor* editor = [XSourceNoteUtil currentEditor];
    if ([editor isKindOfClass:[IDEEditorEmpty class]]) {
        return;
    }
    NSTextView* textView = editor.textView;
    if (nil == textView)
        return;
    
    NSRange range = [textView.selectedRanges[0] rangeValue];
    NSUInteger lineNumber = [[[textView string]substringToIndex:range.location]componentsSeparatedByString:@"\n"].count;
    
    // length of "file://" is 7
    NSString *sourcePath = [[editor.sourceCodeDocument.fileURL absoluteString] substringFromIndex:7];
    
    XSourceNoteEntity *bookmark = [[XSourceNoteEntity alloc]initWithSourcePath:sourcePath withLineNumber:lineNumber];
    [[XSourceNoteModel sharedModel]toggleBookmark:bookmark];
    
    [[XSourceNoteModel sharedModel]saveBookmarks];
    
    // point to the new added bookmark
    self.currentBookmarkIndex = [XSourceNoteModel sharedModel].bookmarks.count - 1;
    
    [[editor valueForKey:@"_sidebarView"]setNeedsDisplay:YES];
}

- (void)nextBookmark{
    [[XSourceNoteModel sharedModel]loadOnceBookmarks];
    
    XSourceNoteModel *model = [XSourceNoteModel sharedModel];
    if(model.bookmarks.count == 0)
        return;
    NSUInteger nextIndex = self.currentBookmarkIndex + 1;
    if(nextIndex >= model.bookmarks.count){
        // 如果超了就回到第一个
        nextIndex = 0;
    }
    
    XSourceNoteEntity *bookmark = [model.bookmarks objectAtIndex:nextIndex];
    [XSourceNoteUtil openSourceFile:bookmark.sourcePath highlightLineNumber:bookmark.lineNumber];
    self.currentBookmarkIndex = nextIndex;
}
- (void)previousBookmark{
    [[XSourceNoteModel sharedModel]loadOnceBookmarks];
    
    XSourceNoteModel *model = [XSourceNoteModel sharedModel];
    if(model.bookmarks.count == 0)
        return;
    NSUInteger previousIndex;
    if(self.currentBookmarkIndex == 0){
        // 如果已经是第一个，则到最后一个
        previousIndex = model.bookmarks.count - 1;
    }else{
        previousIndex = self.currentBookmarkIndex - 1;
    }
    if(previousIndex >= model.bookmarks.count){
        previousIndex = model.bookmarks.count - 1;
    }
    
    XSourceNoteEntity *bookmark = [model.bookmarks objectAtIndex:previousIndex];
    [XSourceNoteUtil openSourceFile:bookmark.sourcePath highlightLineNumber:bookmark.lineNumber];
    self.currentBookmarkIndex = previousIndex;
}
- (void)showBookmarks{
    [[XSourceNoteModel sharedModel]loadOnceBookmarks];
    
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
        [self.windowController refreshBookmarks];
    }
}


@end

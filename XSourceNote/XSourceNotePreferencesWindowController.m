//
//  XSourceNotePreferencesWindowController.m
//  XSourceNote
//
//  Created by everettjf on 10/30/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "XSourceNotePreferencesWindowController.h"
#import "Shortcut.h"
#import "XSourceNoteDefaults.h"
#import "XSourceNoteUtil.h"

@interface XSourceNotePreferencesWindowController ()<NSWindowDelegate>
@property (weak) IBOutlet MASShortcutView *toggleShortcutView;
@property (weak) IBOutlet MASShortcutView *nextShortcutView;
@property (weak) IBOutlet MASShortcutView *prevShortcutView;
@property (weak) IBOutlet MASShortcutView *showShortcutView;

@end

@implementation XSourceNotePreferencesWindowController

-(instancetype)init{
    return [self initWithWindowNibName:@"XSourceNotePreferencesWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[XSourceNoteDefaults sharedDefaults] enableAllMenuShortcuts:NO];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];
    
    XSourceNoteDefaults *config = [XSourceNoteDefaults sharedDefaults];
    
    self.toggleShortcutView.shortcutValue = config.currentShortcutToggle;
    self.toggleShortcutView.shortcutValueChange = ^(MASShortcutView *sender){
        config.currentShortcutToggle = sender.shortcutValue;
        [config synchronize];
    };
    
    self.nextShortcutView.shortcutValue = config.currentShortcutNext;
    self.nextShortcutView.shortcutValueChange = ^(MASShortcutView *sender){
        config.currentShortcutNext = sender.shortcutValue;
        [config synchronize];
    };
    
    self.prevShortcutView.shortcutValue = config.currentShortcutPrev;
    self.prevShortcutView.shortcutValueChange = ^(MASShortcutView *sender){
        config.currentShortcutPrev = sender.shortcutValue;
        [config synchronize];
    };
    
    self.showShortcutView.shortcutValue = config.currentShortcutShow;
    self.showShortcutView.shortcutValueChange = ^(MASShortcutView *sender){
        config.currentShortcutShow = sender.shortcutValue;
        [config synchronize];
    };
}

-(void)windowWillClose:(NSNotification *)notification{
    [[XSourceNoteDefaults sharedDefaults] enableAllMenuShortcuts:YES];
}


@end

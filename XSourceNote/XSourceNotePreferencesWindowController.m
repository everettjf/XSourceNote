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
@property (weak) IBOutlet XSN_MAXShortcutView *toggleShortcutView;
@property (weak) IBOutlet XSN_MAXShortcutView *showShortcutView;
@property (weak) IBOutlet NSPopUpButton *codeStyle;

@property (strong) NSArray *styles;
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
    self.toggleShortcutView.shortcutValueChange = ^(XSN_MAXShortcutView *sender){
        config.currentShortcutToggle = sender.shortcutValue;
        [config synchronize];
    };
    
    self.showShortcutView.shortcutValue = config.currentShortcutShow;
    self.showShortcutView.shortcutValueChange = ^(XSN_MAXShortcutView *sender){
        config.currentShortcutShow = sender.shortcutValue;
        [config synchronize];
    };
    
    self.styles =@[
                 @"",
                 @"``` Code ``` Style",
                 @"{%highlight c%} Code {%endhighlight %} Style"
                 ];
    [self.codeStyle removeAllItems];
    [self.codeStyle addItemsWithTitles:self.styles];
    
    if([config.codeStyle isEqual:@0]){
        [self.codeStyle selectItemAtIndex:1];
    }else{
        [self.codeStyle selectItemAtIndex:2];
    }
    self.codeStyle.title = self.styles[self.codeStyle.indexOfSelectedItem];
}

-(void)windowWillClose:(NSNotification *)notification{
    [[XSourceNoteDefaults sharedDefaults] enableAllMenuShortcuts:YES];
}
- (IBAction)codeStyleSelect:(id)sender {
    
    XSourceNoteDefaults *config = [XSourceNoteDefaults sharedDefaults];
    
    self.codeStyle.title = self.styles[self.codeStyle.indexOfSelectedItem];
    if(self.codeStyle.indexOfSelectedItem == 1){
        [self.codeStyle selectItemAtIndex:0];
        config.codeStyle = @0;
    }else{
        [self.codeStyle selectItemAtIndex:1];
        config.codeStyle = @1;
    }
    [config synchronize];
}


@end

//
//  XSourceNoteWindowController.m
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "XSourceNoteWindowController.h"
#import "XSourceNoteModel.h"
#import "XSourceNoteUtil.h"
#import "XSourceNotePreferencesWindowController.h"

@implementation XSourceNoteTableCellView
@end

@interface XSourceNoteWindowController () <NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *notesTableView;
@property (nonatomic,strong) NSArray *notes;
@property (nonatomic,strong) XSourceNotePreferencesWindowController *preferencesWindowController;

@end

@implementation XSourceNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    self.notesTableView.action = @selector(onTableViewClick:);
    
    [self refreshNotes];
    
    [[XSourceNoteModel sharedModel] addObserver:self forKeyPath:@"notes" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc{
    [[XSourceNoteModel sharedModel] removeObserver:self forKeyPath:@"notes"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"notes"]){
        [self refreshNotes];
    }
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    XSourceNoteTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if([tableColumn.identifier isEqualToString:@"NoteColumn"]){
        XSourceNoteEntity *note = [self.notes objectAtIndex:row];
        cellView.titleField.stringValue = [NSString stringWithFormat:@"%@:%lu",[note.sourcePath lastPathComponent],note.lineNumber];
        cellView.subtitleField.stringValue = note.sourcePath;
    }
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.notes.count;
}


-(void)refreshNotes{
    self.notes = [XSourceNoteModel sharedModel].notes;
    [self.notesTableView reloadData];
}

-(XSourceNoteEntity*)selectedNote{
    NSInteger selectedRow = self.notesTableView.selectedRow;
    if(selectedRow < 0 || selectedRow >= self.notes.count){
        return nil;
    }
    
    XSourceNoteEntity *note = [self.notes objectAtIndex:selectedRow];
    return note;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    NSLog(@"selection did change");
}
- (IBAction)removeNoteClicked:(id)sender {
    XSourceNoteEntity *note = [self selectedNote];
    if(nil == note)
        return;
    [[XSourceNoteModel sharedModel]removeNote:note.sourcePath lineNumber:note.lineNumber];
    [[XSourceNoteModel sharedModel]saveNotes];
}
- (IBAction)clearNoteClicked:(id)sender {
    BOOL shouldClear = NO;
    if(_notes.count > 1){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Clear all notes ?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            shouldClear = YES;
        }
    }else{
        shouldClear = YES;
    }
    
    if(shouldClear){
        [[XSourceNoteModel sharedModel]clearNotes];
        [[XSourceNoteModel sharedModel]saveNotes];
    }
}
- (IBAction)helpClicked:(id)sender {
    NSString *githubURLString = @"http://github.com/everettjf/XSourceNote";
    NSString *versionString = [[NSBundle bundleForClass:[XSourceNoteWindowController class]]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *xcodeVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Source on GitHub"];
    [alert setMessageText:@"XSourceNote"];
    [alert setInformativeText:[NSString stringWithFormat:@"Author:everettjf\nGitHub:%@\nVersion:%@\nXcode:%@",
                               githubURLString,
                               versionString,
                               xcodeVersion
                               ]];
    [alert setAlertStyle:NSWarningAlertStyle];
    NSModalResponse resp = [alert runModal];
    if(resp == NSAlertSecondButtonReturn){
        // Star
        [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:githubURLString]];
    }
}

-(void)onTableViewClick:(id)sender{
//    NSLog(@"row click");
    NSInteger row = self.notesTableView.clickedRow;
    if(row < 0 || row >= self.notes.count)
        return;
    
    XSourceNoteEntity *note = [self selectedNote];
    if(nil == note)
        return;
    
    // locate note
    [XSourceNoteUtil openSourceFile:note.sourcePath highlightLineNumber:note.lineNumber];
}
- (IBAction)showPreferencesClicked:(id)sender {
    self.preferencesWindowController = [[XSourceNotePreferencesWindowController alloc]init];
    [self.preferencesWindowController.window makeKeyAndOrderFront:sender];
}

@end

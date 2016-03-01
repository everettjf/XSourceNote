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
#import "XSourceNoteStorage.h"

@implementation XSourceNoteTableCellView
@end

@interface XSourceNoteWindowController () <NSTableViewDelegate,NSTableViewDataSource>
@property (strong) NSArray *notes;

@property (nonatomic,strong) XSourceNotePreferencesWindowController *preferencesWindowController;

// Information
@property (weak) IBOutlet NSTextField *uniqueVersionAddressTextField;
@property (weak) IBOutlet NSTextField *projectNameTextField;
@property (weak) IBOutlet NSTextField *officialSiteTextField;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionTextView;

// Project Note
@property (unsafe_unretained) IBOutlet NSTextView *projectNoteTextView;

// Lines Note
@property (weak) IBOutlet NSOutlineView *linesNoteTableView;

// Summarize
@property (unsafe_unretained) IBOutlet NSTextView *summarizeTextView;

@end

@implementation XSourceNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    
    if(![[XSourceNoteStorage sharedStorage] ensureDB]){
        NSLog(@"xs:Database is not ready");
    }
    
    [self refreshTabInformation];
    [self refreshNotes];
    
}

- (void)dealloc{
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    XSourceNoteTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
//    if([tableColumn.identifier isEqualToString:@"NoteColumn"]){
//        XSourceNoteEntity *note = [self.notes objectAtIndex:row];
//        cellView.titleField.stringValue = [NSString stringWithFormat:@"%@:%lu",[note.sourcePath lastPathComponent],note.lineNumber];
//        cellView.subtitleField.stringValue = note.sourcePath;
//    }
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.notes.count;
}


-(void)refreshNotes{
    self.notes = [XSourceNoteModel sharedModel].notes;
//    [self.notesTableView reloadData];
}

//-(XSourceNoteEntity*)selectedNote{
//    NSInteger selectedRow = self.notesTableView.selectedRow;
//    if(selectedRow < 0 || selectedRow >= self.notes.count){
//        return nil;
//    }
//    
//    XSourceNoteEntity *note = [self.notes objectAtIndex:selectedRow];
//    return note;
//}


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

//-(void)onTableViewClick:(id)sender{
////    NSLog(@"row click");
//    NSInteger row = self.notesTableView.clickedRow;
//    if(row < 0 || row >= self.notes.count)
//        return;
//    
//    XSourceNoteEntity *note = [self selectedNote];
//    if(nil == note)
//        return;
//    
//    // locate note
//    [XSourceNoteUtil openSourceFile:note.sourcePath highlightLineNumber:note.lineNumber];
//}
- (IBAction)showPreferencesClicked:(id)sender {
    self.preferencesWindowController = [[XSourceNotePreferencesWindowController alloc]init];
    [self.preferencesWindowController.window makeKeyAndOrderFront:sender];
}
- (IBAction)saveInformationClicked:(id)sender {
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    
    st.projectUniqueAddress = self.uniqueVersionAddressTextField.stringValue;
    st.projectName = self.projectNameTextField.stringValue;
    st.projectSite = self.officialSiteTextField.stringValue;
    st.projectDescription = self.descriptionTextView.string;
}

- (void)refreshTabInformation{
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    
    self.uniqueVersionAddressTextField.stringValue = st.projectUniqueAddress;
    self.projectNameTextField.stringValue = st.projectName;
    self.officialSiteTextField.stringValue = st.projectSite;
    self.descriptionTextView.string = st.projectDescription;
}

@end

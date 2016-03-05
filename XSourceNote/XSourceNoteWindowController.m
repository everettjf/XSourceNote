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
#import "Note.h"

@implementation XSourceNoteTableCellView

- (void)setLineNote:(Note *)lineNote{
    _lineNote = lineNote;
    
    NSString *fileName = [_lineNote.pathLocal lastPathComponent];
    NSString *title;
    if([_lineNote.lineNumberBegin isEqualToNumber:_lineNote.lineNumberEnd]){
        title = [NSString stringWithFormat:@"%@ [%@]", fileName, _lineNote.lineNumberBegin];
    }else{
        title = [NSString stringWithFormat:@"%@ [%@,%@]", fileName, _lineNote.lineNumberBegin,_lineNote.lineNumberEnd];
    }
    NSString *content = _lineNote.content;
    if(!content) content = @"";
    
    _titleField.stringValue = title;
    _contentField.stringValue = content;
    
    _contentField.maximumNumberOfLines = 2;
    _contentField.editable = NO;
}

@end

@interface XSourceNoteWindowController () <NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic,strong) XSourceNotePreferencesWindowController *preferencesWindowController;

// Information
@property (weak) IBOutlet NSTextField *uniqueVersionAddressTextField;
@property (weak) IBOutlet NSTextField *projectNameTextField;
@property (weak) IBOutlet NSTextField *officialSiteTextField;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionTextView;

// Project Note
@property (unsafe_unretained) IBOutlet NSTextView *projectNoteTextView;

// Summarize
@property (unsafe_unretained) IBOutlet NSTextView *summarizeTextView;

// Lines Note
@property (weak) IBOutlet NSTableView *lineNoteTableView;

@property (unsafe_unretained) IBOutlet NSTextView *currentNoteView;

@property (strong) NSArray *lineNotes;

@end

@implementation XSourceNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    self.lineNotes = @[];
    
    [self refreshTabFields];
    [self refreshNotes];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationLineNotesChange:) name:XSourceNoteModelLineNotesChanged object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void) notificationLineNotesChange:(NSNotification*)obj{
    [self refreshNotes];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    XSourceNoteTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    Note *lineNote = [self.lineNotes objectAtIndex:row];
    cellView.lineNote = lineNote;
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.lineNotes.count;
}


-(void)refreshNotes{
    [[XSourceNoteModel sharedModel]fetchAllNotes:^(NSArray *notes) {
        self.lineNotes = notes;
        [self.lineNoteTableView reloadData];
    }];
}
- (IBAction)onTableViewClicked:(id)sender {
    NSLog(@"row click");
    NSInteger row = self.lineNoteTableView.clickedRow;
    if(row < 0 || row >= self.lineNotes.count)
        return;
    
//    XSourceNoteEntity *note = [self selectedNote];
//    if(nil == note)
//        return;
//    
//    // locate note
//    [XSourceNoteUtil openSourceFile:note.sourcePath highlightLineNumber:note.lineNumber];

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

- (void)refreshTabFields{
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    
    self.uniqueVersionAddressTextField.stringValue = st.projectUniqueAddress;
    self.projectNameTextField.stringValue = st.projectName;
    self.officialSiteTextField.stringValue = st.projectSite;
    self.descriptionTextView.string = st.projectDescription;
    
    self.projectNoteTextView.string = st.projectNote;
    self.summarizeTextView.string = st.projectSummarize;
}
- (IBAction)saveProjectNote:(id)sender {
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    st.projectNote = self.projectNoteTextView.string;
}
- (IBAction)saveSummarize:(id)sender {
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    st.projectSummarize = self.summarizeTextView.string;
}



@end

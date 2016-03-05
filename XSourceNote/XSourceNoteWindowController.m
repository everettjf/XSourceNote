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
#import "XSourceNoteTableView.h"

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

@interface XSourceNoteWindowController () <NSTableViewDelegate,NSTableViewDataSource, NSTextViewDelegate>

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
@property (weak) IBOutlet XSourceNoteTableView *lineNoteTableView;

@property (unsafe_unretained) IBOutlet NSTextView *currentNoteView;

@property (strong) NSMutableArray *lineNotes;
@property (strong) Note *currentNote;

@end

@implementation XSourceNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    self.lineNotes = [NSMutableArray new];
    
    self.lineNoteTableView.deleteKeyAction = @selector(onDeleteLineNote:);
    self.currentNoteView.delegate = self;
    
    [self refreshTabFields];
    [self refreshNotes];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationLineNotesChange:) name:XSourceNoteModelLineNotesChanged object:nil];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self _saveCurrentNote];
    });
    dispatch_resume(timer);
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
        self.lineNotes = [notes mutableCopy];
        [self.lineNoteTableView reloadData];
    }];
}
- (IBAction)onTableViewClicked:(id)sender {
    NSLog(@"row click");
    NSInteger row = self.lineNoteTableView.clickedRow;
    if(row < 0 || row >= self.lineNotes.count)
        return;
    
    Note *note = [self _selectedNote];
    if(_currentNote)
        NSLog(@"current note : %@", _currentNote.content);
    NSLog(@"select note : %@", note.content);
    
    [self _saveCurrentNote];
    
    // show note content
    [self _showNewNoteContent:note];
    
    // set new current note
    self.currentNote = note;
    
    // locate in editor
    [XSourceNoteUtil openSourceFile:note.pathLocal highlightLineNumber:note.lineNumberBegin.unsignedIntegerValue];
}

- (void)_showNewNoteContent:(Note*)note{
    // show new note content
    NSString *content = note.content;
    if(!content) content = @"";
    
    self.currentNoteView.string = content;
}

-(Note*)_selectedNote{
    NSInteger selectedRow = self.lineNoteTableView.selectedRow;
    if(selectedRow < 0 || selectedRow >= self.lineNotes.count){
        return nil;
    }
    return [self.lineNotes objectAtIndex:selectedRow];
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

- (void)onDeleteLineNote:(id)sender{
    Note *note = [self _selectedNote];
    if(!note)return;
    
    if(note.content){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Confirm"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Current note is not empty, please confirm to delete."];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] != NSAlertFirstButtonReturn) {
            return;
        }
    }
    
    [[XSourceNoteModel sharedModel]removeLineNote:[note noteIndex]];
    
    [self refreshNotes];
}

- (void)_saveCurrentNote{
    if(!_currentNote)return;
    NSLog(@"Auto saving note");
    
    _currentNote.content = self.currentNoteView.string;
    _currentNote.updatedAt = [NSDate date];
    
    [[XSourceNoteStorage sharedStorage]save];
}


@end

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
#import "XSourceNoteTableView.h"
#import "XSourceNoteTableCellView.h"


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

@property (strong) NSArray *lineNotes;
@property (copy) NSString *currentNoteUniqueID;

@end

@implementation XSourceNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    self.lineNotes = @[];
    
    self.lineNoteTableView.deleteKeyAction = @selector(onDeleteLineNote:);
    self.currentNoteView.delegate = self;
    
    [self refreshTabFields];
    [self refreshNotes];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationLineNotesChange:) name:XSourceNoteModelLineNotesChanged object:nil];
    
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(timer, ^{
//        [self _saveCurrentNote];
//    });
//    dispatch_resume(timer);
    
    self.currentNoteView.editable = NO;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void) notificationLineNotesChange:(NSNotification*)obj{
    [self refreshNotes];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    XSourceNoteTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if([tableColumn.identifier isEqualToString:@"LineColumn"]){
        XSourceNoteEntity *lineNote = [self.lineNotes objectAtIndex:row];
        cellView.lineNote = lineNote;
    }
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
    XSourceNoteEntity *note = [self _selectedNote];
    if(!note)return;
    
    [self _showNewNote:note];
    
    self.currentNoteView.editable = YES;
    self.currentNoteUniqueID = note.uniqueID;
    
//    [XSourceNoteUtil openSourceFile:note.source highlightLineNumber:note.begin];
}


-(XSourceNoteEntity*)_selectedNote{
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
    XSourceNoteEntity *note = [self _selectedNote];
    if(!note)return;
    
    if(note.content && ![note.content isEqualToString:@""]){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Confirm"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Current note is not empty, please confirm to delete."];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] != NSAlertFirstButtonReturn) {
            return;
        }
    }
    
    [[XSourceNoteModel sharedModel]removeLineNote:note];
    
    [self refreshNotes];
    
}


- (void)_showNewNote:(XSourceNoteEntity*)note{
    self.window.title = [note title];
    
    // show new
    NSString *content = note.content;//[[XSourceNoteStorage sharedStorage]readLineNote:[note uniqueID]];
    if(!content) content = @"";
    
    self.currentNoteView.string = content;
}

- (IBAction)reloadClicked:(id)sender {
    
    [self refreshNotes];
}
- (IBAction)saveClicked:(id)sender {
    
    if(self.currentNoteUniqueID){
        NSString *content = self.currentNoteView.string;
        [[XSourceNoteStorage sharedStorage]updateLineNote:self.currentNoteUniqueID content:content];
    }
}

@end

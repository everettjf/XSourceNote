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
#import "XSourceNoteFormatter.h"


@interface XSourceNoteWindowController () <NSTableViewDelegate,NSTableViewDataSource, NSTextViewDelegate>
@property (weak) IBOutlet NSTabView *tabView;

@property (nonatomic,strong) XSourceNotePreferencesWindowController *preferencesWindowController;

// Information
@property (weak) IBOutlet NSTextField *rootPathTextField;
@property (weak) IBOutlet NSTextField *repoTextField;
@property (weak) IBOutlet NSTextField *revisionTextField;

@property (weak) IBOutlet NSTextField *projectNameTextField;
@property (weak) IBOutlet NSTextField *officialSiteTextField;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionTextView;

// Project Note
@property (unsafe_unretained) IBOutlet NSTextView *projectNoteTextView;

// Summarize
@property (unsafe_unretained) IBOutlet NSTextView *summarizeTextView;

// Lines Note
@property (weak) IBOutlet XSourceNoteTableView *lineNoteTableView;

// Tool
@property (unsafe_unretained) IBOutlet NSTextView *filePrefixTextView;

@property (unsafe_unretained) IBOutlet NSTextView *currentNoteView;
@property (unsafe_unretained) IBOutlet NSTextView *currentSourceView;


@property (strong) NSArray *notes;
@property (copy) NSString *currentNoteUniqueID;

@end

@implementation XSourceNoteWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.level = NSFloatingWindowLevel;
    self.window.hidesOnDeactivate = YES;
    self.notes = @[];
    
    self.lineNoteTableView.deleteKeyAction = @selector(onDeleteLineNote:);
    self.currentNoteView.delegate = self;
    
    [self refreshTabFields];
    [self refreshNotes];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationLineNotesChange:) name:XSourceNoteModelLineNotesChanged object:nil];
    
    [self startSaveTimer];
    
    self.currentNoteView.editable = NO;
    self.currentSourceView.editable = NO;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)startSaveTimer{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _saveCurrent];
        
        [self startSaveTimer];
    });
}

-(void) notificationLineNotesChange:(NSNotification*)obj{
    [self refreshNotes];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    XSourceNoteTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if([tableColumn.identifier isEqualToString:@"LineColumn"]){
        XSourceNoteEntityObject *note = [self.notes objectAtIndex:row];
        cellView.note = note;
    }
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.notes.count;
}


-(void)refreshNotes{
    [[XSourceNoteModel sharedModel]fetchAllNotes:^(NSArray *notes) {
        NSMutableArray *dataset = [NSMutableArray new];
        [dataset addObject:[XSourceNoteBasicInformationEntity new]];
        [dataset addObject:[XSourceNoteProjectNoteEntity new]];
        [dataset addObject:[XSourceNoteProjectSummarizeEntity new]];
        [dataset addObject:[XSourceNoteProjectToolEntity new]];
        
        for (XSourceNoteEntityObject *note in notes) {
            [dataset addObject:note];
        }
        self.notes = dataset;
        
        [self.lineNoteTableView reloadData];
    }];
}
- (IBAction)onTableViewClicked:(id)sender {
    XSourceNoteEntityObject *note = [self _selectedNote];
    if(!note)return;
    
    switch (note.type) {
        case XSourceNoteEntityTypeBasicInformation:
            [self.tabView selectTabViewItemAtIndex:0];
            break;
        case XSourceNoteEntityTypeProjectNote:
            [self.tabView selectTabViewItemAtIndex:1];
            break;
        case XSourceNoteEntityTypeSummarize:
            [self.tabView selectTabViewItemAtIndex:3];
            break;
        case XSourceNoteEntityTypeTool:
            [self.tabView selectTabViewItemAtIndex:4];
            break;
        case XSourceNoteEntityTypeLineNote:{
            [self.tabView selectTabViewItemAtIndex:2];
            
            [self _saveCurrent];
            XSourceNoteLineEntity *lineNote = (id)note;
            
            [self _showNewNote:lineNote];
            
            self.currentNoteView.editable = YES;
            self.currentNoteUniqueID = lineNote.uniqueID;
            
            [XSourceNoteUtil openSourceFile:lineNote.source highlightLineNumber:lineNote.begin];
            
            [self refreshNotes];
            
            break;
        }
        default:
            break;
    }
    
}


-(XSourceNoteEntityObject*)_selectedNote{
    NSInteger selectedRow = self.lineNoteTableView.selectedRow;
    if(selectedRow < 0 || selectedRow >= self.notes.count){
        return nil;
    }
    return [self.notes objectAtIndex:selectedRow];
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

- (void)refreshTabFields{
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    self.rootPathTextField.stringValue = st.rootPath;
    
    self.projectNameTextField.stringValue = st.projectName;
    self.officialSiteTextField.stringValue = st.projectSite;
    self.repoTextField.stringValue = st.projectRepo;
    self.revisionTextField.stringValue = st.projectRevision;
    self.descriptionTextView.string = st.projectDescription;
    
    self.projectNoteTextView.string = st.projectNote;
    self.summarizeTextView.string = st.projectSummarize;
    
    self.filePrefixTextView.string = st.filePrefix;
}

- (void)onDeleteLineNote:(id)sender{
    XSourceNoteEntityObject *obj = [self _selectedNote];
    if(!obj)return;
    if(obj.type != XSourceNoteEntityTypeLineNote)return;
    XSourceNoteLineEntity *note = (id)obj;
    
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


- (void)_showNewNote:(XSourceNoteLineEntity*)note{
    self.window.title = [note title];
    
    // show new
    NSString *content = note.content;//[[XSourceNoteStorage sharedStorage]readLineNote:[note uniqueID]];
    if(!content) content = @"";
    
    NSString *code = note.code;
    if(!code)code = @"";
    
    self.currentNoteView.string = content;
    self.currentSourceView.string = code;
}

- (void)_saveCurrent{
    if(self.currentNoteUniqueID){
        NSString *content = self.currentNoteView.string;
        [[XSourceNoteStorage sharedStorage]updateLineNote:self.currentNoteUniqueID content:content];
    }
    
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    
    st.rootPath = [self.rootPathTextField.stringValue copy];
    
    st.projectName = [self.projectNameTextField.stringValue copy];
    st.projectSite = [self.officialSiteTextField.stringValue copy];
    st.projectRepo = [self.repoTextField.stringValue copy];
    st.projectRevision = [self.revisionTextField.stringValue copy];
    st.projectDescription = [self.descriptionTextView.string copy];
    
    st.projectNote = [self.projectNoteTextView.string copy];
    st.projectSummarize = [self.summarizeTextView.string copy];
    
    st.filePrefix = [self.filePrefixTextView.string copy];
}
- (IBAction)exportToMarkdown:(id)sender {
    XSourceNoteStorage *store = [XSourceNoteStorage sharedStorage];
    
    NSSavePanel *save = [NSSavePanel savePanel];
    save.nameFieldStringValue = [NSString stringWithFormat:@"%@",store.projectName];
    save.message = @"Save to ?";
    save.allowsOtherFileTypes = YES;
    save.allowedFileTypes = @[@"md",@"markdown"];
    save.extensionHidden = YES;
    save.canCreateDirectories = YES;
    
    [save beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result != NSFileHandlingPanelOKButton)
            return;
        NSString *filePath = [[save URL]path];
        
        if([[XSourceNoteFormatter sharedFormatter]saveTo:filePath]){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            alert.messageText = @"Succeed";
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
        }else{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            alert.messageText = @"Failed";
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert runModal];
        }
    }];
    
}

- (IBAction)selectRootPathClicked:(id)sender {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.canChooseFiles = NO;
    open.canChooseDirectories = YES;
    open.allowsMultipleSelection = NO;
    if([open runModal] != NSModalResponseOK){
        return;
    }
    
    NSString *path = [open.URL path];
    
    XSourceNoteStorage *st = [XSourceNoteStorage sharedStorage];
    st.rootPath = path;
    
    self.rootPathTextField.stringValue = st.rootPath;
}

@end

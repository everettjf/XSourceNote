//
//  XSourceNoteModel.m
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "XSourceNoteModel.h"
#import "XSourceNoteUtil.h"
#import "MagicalRecord.h"
#import "Note.h"
#import "Store.h"

@implementation XSourceNoteEntity

-(instancetype)initWithSourcePath:(NSString *)sourcePath withLineNumber:(NSUInteger)lineNumber{
    self = [super init];
    if(self){
        self.sourcePath = sourcePath;
        self.lineNumber = lineNumber;
        self.comment = @"";
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.sourcePath = [aDecoder decodeObjectForKey:@"sourcePath"];
        self.lineNumber = [aDecoder decodeIntegerForKey:@"lineNumber"];
        self.comment = [aDecoder decodeObjectForKey:@"comment"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_sourcePath forKey:@"sourcePath"];
    [aCoder encodeInteger:_lineNumber forKey:@"lineNumber"];
    [aCoder encodeObject:_comment forKey:@"comment"];
}

@end

@interface XSourceNoteModel ()

@property (nonatomic,strong) NSMutableArray *notes;

// for fast check
@property (nonatomic,strong) NSMutableSet<NSString*> *markset;

@end

@implementation XSourceNoteModel

+(XSourceNoteModel *)sharedModel{
    static XSourceNoteModel *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[XSourceNoteModel alloc]init];
    });
    return inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notes = [[NSMutableArray alloc]init];
        self.markset = [[NSMutableSet alloc]init];
    }
    return self;
}
static inline NSString* XSourceNote_HashLine(NSString*sourcePath,NSUInteger lineNumber){
    return [NSString stringWithFormat:@"%lu-%lu",lineNumber,[sourcePath hash]];
}

-(void)insertObject:(XSourceNoteEntity *)object inNotesAtIndex:(NSUInteger)index{
    [_notes insertObject:object atIndex:index];
    [_markset addObject:XSourceNote_HashLine(object.sourcePath, object.lineNumber)];
}
-(void)removeObjectFromNotesAtIndex:(NSUInteger)index{
    XSourceNoteEntity *object = [_notes objectAtIndex:index];
    if(nil == object)
        return;
    [_notes removeObjectAtIndex:index];
    [_markset removeObject:XSourceNote_HashLine(object.sourcePath, object.lineNumber)];
}

-(void)addNote:(XSourceNoteEntity *)note{
    [self insertObject:note inNotesAtIndex:self.notes.count];
}

-(void)clearNotes{
    while(_notes.count > 0){
        [self removeObjectFromNotesAtIndex:_notes.count - 1];
    }
    [_markset removeAllObjects];
}

-(void)removeNote:(NSString *)sourcePath lineNumber:(NSUInteger)lineNumber{
    [_notes enumerateObjectsUsingBlock:^(XSourceNoteEntity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([sourcePath isEqualToString:obj.sourcePath] && lineNumber == obj.lineNumber){
            [self removeObjectFromNotesAtIndex:idx];
            *stop = YES;
        }
    }];
}

-(BOOL)hasNote:(NSString *)sourcePath lineNumber:(NSUInteger)lineNumber{
    return [_markset containsObject:XSourceNote_HashLine(sourcePath, lineNumber)];
}

-(BOOL)toggleNote:(XSourceNoteEntity *)note{
    if([self hasNote:note.sourcePath lineNumber:note.lineNumber]){
        [self removeNote:note.sourcePath lineNumber:note.lineNumber];
        return YES;
    }
    [self addNote:note];
    return NO;
}

-(void)saveNotes{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *workspace = [self currentWorkspaceSettingFilePath];
        if(workspace == nil)
            return;
        
        if(self.notes.count == 0){
            [[NSFileManager defaultManager] removeItemAtPath:workspace error:nil];
        }else{
            [NSKeyedArchiver archiveRootObject:self.notes toFile:workspace];
        }
    });
}
-(void)loadNotes{
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[self currentWorkspaceSettingFilePath]];
    if(nil == data)
        return;
    
    self.notes = [data mutableCopy];
    [self refreshHashset];
}
-(void)refreshHashset{
    [_markset removeAllObjects];
    [self.notes enumerateObjectsUsingBlock:^(XSourceNoteEntity* _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
        [_markset addObject:XSourceNote_HashLine(object.sourcePath, object.lineNumber)];
    }];
}


-(NSString*)currentWorkspaceSettingFilePath{
    static NSString *cachedWorkspaceFilePath = nil;
    NSString *workspaceFilePath = [XSourceNoteUtil currentWorkspaceFilePath];
    if(workspaceFilePath == nil){
        workspaceFilePath = cachedWorkspaceFilePath;
    }else{
        cachedWorkspaceFilePath = [workspaceFilePath copy];
    }
    
    if(workspaceFilePath == nil)
        return nil;
    
    NSString *settingFileName = [NSString stringWithFormat:@"%@-%lu.XSourceNote",
                                 [workspaceFilePath lastPathComponent],
                                 [workspaceFilePath hash]
                                 ];
    
    return [[XSourceNoteUtil settingDirectory] stringByAppendingPathComponent:settingFileName];
}

-(void)loadOnceNotes{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadNotes];
    });
}




@end

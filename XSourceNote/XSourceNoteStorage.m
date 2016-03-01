//
//  XSourceNoteStorage.m
//  XSourceNote
//
//  Created by everettjf on 16/3/1.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteStorage.h"
#import "XSourceNoteUtil.h"
#import "Store.h"
#import "Note.h"

static NSString * const kStoreKeyProjectUniqueAddress = @"ProjectUniqueAddress";
static NSString * const kStoreKeyProjectName = @"ProjectName";
static NSString * const kStoreKeyProjectSite = @"ProjectSite";
static NSString * const kStoreKeyProjectDescription = @"ProjectDescription";
static NSString * const kStoreKeyProjectNote = @"ProjectNote";
static NSString * const kStoreKeyProjectSummarize = @"ProjectSummarize";

@interface XSourceNoteStorage ()
{
    NSURL *_notePath;
    BOOL _dbReady;
}

@end

@implementation XSourceNoteStorage

+ (XSourceNoteStorage *)sharedStorage{
    static XSourceNoteStorage *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         inst = [[XSourceNoteStorage alloc]init];
    });
    return inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self ensureDB];
    }
    return self;
}

- (NSURL *)notePath{
    if(_notePath) return _notePath;
    
    NSString *workspaceFilePath = [XSourceNoteUtil currentWorkspaceFilePath];
    if(workspaceFilePath == nil)
        return nil;
    
    NSString *projectName = [workspaceFilePath lastPathComponent];
    projectName = [projectName stringByDeletingPathExtension];
    
    NSString *settingFileName = [NSString stringWithFormat:@"%@_%lu.xsnote",
                                 projectName,
                                 [workspaceFilePath hash] % 1000
                                 ];
    
    NSString *noteUrlString =[[XSourceNoteUtil notesDirectory] stringByAppendingPathComponent:settingFileName];
    _notePath = [NSURL fileURLWithPath:noteUrlString];
    NSLog(@"note path = %@", _notePath);
    return _notePath;
}

- (BOOL)ensureDB{
    if(_dbReady)return YES;
    
    if(!self.notePath)return NO;
    
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSManagedObjectModel *model = [NSManagedObjectModel MR_newModelNamed:@"XSourceNote.momd" inBundle:currentBundle];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator MR_addAutoMigratingSqliteStoreAtURL:self.notePath];
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:coordinator];
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:coordinator];
    
    _dbReady = YES;
    return YES;
}

- (void)_saveValue:(NSString *)value forKey:(NSString *)key{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        Store *store = [Store MR_findFirstOrCreateByAttribute:@"key" withValue:key inContext:localContext];
        if(!store) return;
        store.value = value;
    }];
}

- (NSString *)_readValueForKey:(NSString *)key{
    Store *store = [Store MR_findFirstByAttribute:@"key" withValue:key];
    if(!store) return @"";
    NSLog(@"xs:key = %@ ,value = %@", store.key ,store.value );
    if(!store.value)
        return @"";
    return store.value;
}

- (void)setProjectUniqueAddress:(NSString *)projectUniqueAddress{
    [self _saveValue:projectUniqueAddress forKey:kStoreKeyProjectUniqueAddress];
}
- (NSString *)projectUniqueAddress{
    return [self _readValueForKey:kStoreKeyProjectUniqueAddress];
}

- (void)setProjectName:(NSString *)projectName{
    [self _saveValue:projectName forKey:kStoreKeyProjectName];
}
- (NSString *)projectName{
    return [self _readValueForKey:kStoreKeyProjectName];
}

- (void)setProjectSite:(NSString *)projectSite{
    [self _saveValue:projectSite forKey:kStoreKeyProjectSite];
}

- (NSString *)projectSite{
    return [self _readValueForKey:kStoreKeyProjectSite];
}

- (void)setProjectDescription:(NSString *)projectDescription{
    [self _saveValue:projectDescription forKey:kStoreKeyProjectDescription];
}

- (NSString *)projectDescription{
    return [self _readValueForKey:kStoreKeyProjectDescription];
}

- (void)setProjectNote:(NSString *)projectNote{
    [self _saveValue:projectNote forKey:kStoreKeyProjectNote];
}

- (NSString *)projectNote{
    return [self _readValueForKey:kStoreKeyProjectNote];
}

- (void)setProjectSummarize:(NSString *)projectSummarize{
    [self _saveValue:projectSummarize forKey:kStoreKeyProjectSummarize];
}
- (NSString *)projectSummarize{
    return [self _readValueForKey:kStoreKeyProjectSummarize];
}

@end

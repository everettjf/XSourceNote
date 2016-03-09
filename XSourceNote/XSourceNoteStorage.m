//
//  XSourceNoteStorage.m
//  XSourceNote
//
//  Created by everettjf on 16/3/1.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import "XSourceNoteStorage.h"
#import "XSourceNoteUtil.h"
#import "XSStore.h"

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

@property (strong) NSManagedObjectContext *managedObjectContext;

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
    
    NSString *settingFileName = [NSString stringWithFormat:@"%@_%lu.db",
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
    
    NSURL *modelURL = [currentBundle URLForResource:@"XSourceNote" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    
    NSURL *storeURL = self.notePath;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
    
    _dbReady = YES;
    return YES;
}

- (void)_saveValue:(NSString *)value forKey:(NSString *)key{
    [self.managedObjectContext performBlockAndWait:^{
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XSStore"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if(error)
            return;
        
        XSStore *store;
        if(results.count == 0){
            store = [NSEntityDescription insertNewObjectForEntityForName:@"XSStore" inManagedObjectContext:self.managedObjectContext];
            store.key = key;
        }else{
            store = results.firstObject;
        }
        store.value = value;
        
        if(![self.managedObjectContext save:&error]){
            NSLog(@"save value error :%@",error);
        }
    }];
}

- (NSString *)_readValueForKey:(NSString *)key{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XSStore"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if(error)
        return nil;
    
    XSStore *store = results.firstObject;
    if(!store.value)
        return @"";
    return [store.value copy];
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

- (void)_internalSave{
    if(! [self.managedObjectContext hasChanges]){
        NSLog(@"has no changed");
        return;
    }
    
    NSError *error;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"save note failed :%@",error);
    }
}

- (void)addLineNote:(XSourceNoteIndex *)index{
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XSNote"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", index.uniqueID];
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if(error) return;
        
        XSNote *note;
        if(results.count == 0){
            // Create
            note = [NSEntityDescription insertNewObjectForEntityForName:@"XSNote" inManagedObjectContext:self.managedObjectContext];
            note.uniqueID = index.uniqueID;
            note.createdAt = [NSDate date];
            note.order = @10000;
            note.content = @"";
        }else{
            note = results.firstObject;
        }
        
        note.pathLocal = index.source;
        note.lineNumberBegin = @(index.begin);
        note.lineNumberEnd = @(index.end);
        note.updatedAt = [NSDate date];
        
        [self _internalSave];
    }];
}

- (XSNote *)_fetchLineNoteByUniqueID:(NSString *)uniqueID{
    __block XSNote *note = nil;
    [self.managedObjectContext performBlockAndWait:^{
        note = [self _internalFetchLineNoteByUniqueID:uniqueID];
    }];
    return note;
}

- (XSNote *)_internalFetchLineNoteByUniqueID:(NSString *)uniqueID{
    XSNote *note = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XSNote"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", uniqueID];
    
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if(error) return nil;
    
    if(results.count > 0){
        note = results.firstObject;
    }
    return note;
}


- (XSNote *)fetchLineNote:(XSourceNoteIndex *)index{
    return [self _fetchLineNoteByUniqueID:index.uniqueID];
}

- (NSArray *)fetchAllLineNotes{
    __block NSArray *results;
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XSNote"];
        request.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO],
                                    [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES],
                                    ];
        NSError *error;
        results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if(error){
            NSLog(@"fetch all note error %@",error);
        }
    }];
    
    return results;
}
- (void)removeLineNote:(NSString *)uniqueID{
    [self.managedObjectContext performBlockAndWait:^{
        XSNote *note = [self _internalFetchLineNoteByUniqueID:uniqueID];
        if(!note)return;
        [self.managedObjectContext deleteObject:note];
        
        [self _internalSave];
    }];
}

- (void)updateLineNote:(NSString *)uniqueID content:(NSString *)content{
    [self.managedObjectContext performBlockAndWait:^{
        XSNote *note = [self _internalFetchLineNoteByUniqueID:[uniqueID copy]];
        if(!note)return;
        
        note.content = [content copy];;
        note.updatedAt = [NSDate date];
        
        [self _internalSave];
    }];
}



@end

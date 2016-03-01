//
//  XSourceNoteModel.h
//  XSourceNote
//
//  Created by everettjf on 10/2/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XSourceNoteEntity : NSObject<NSCoding>
@property (nonatomic,strong) NSString *sourcePath;
@property (nonatomic,assign) NSUInteger lineNumber;
@property (nonatomic,strong) NSString *comment;

-(instancetype)initWithSourcePath:(NSString*)sourcePath withLineNumber:(NSUInteger)lineNumber;
@end


@interface XSourceNoteModel : NSObject

+(XSourceNoteModel *)sharedModel;

@property (nonatomic,strong,readonly) NSMutableArray *notes;

-(void)addNote:(XSourceNoteEntity*)note;
-(void)removeNote:(NSString*)sourcePath lineNumber:(NSUInteger)lineNumber;
-(BOOL)hasNote:(NSString*)sourcePath lineNumber:(NSUInteger)lineNumber;
-(void)clearNotes;

-(BOOL)toggleNote:(XSourceNoteEntity*)note;

-(void)saveNotes;
-(void)loadNotes;

-(void)loadOnceNotes;


-(void)saveValue:(NSString*)value forKey:(NSString*)key;
-(NSString*)readValueForKey:(NSString*)key;


@end



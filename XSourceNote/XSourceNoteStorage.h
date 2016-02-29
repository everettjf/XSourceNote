//
//  XSourceNoteStorage.h
//  XSourceNote
//
//  Created by everettjf on 16/3/1.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagicalRecord.h"

@interface XSourceNoteStorage : NSObject
@property (strong,nonatomic,readonly) NSURL *notePath;

+ (XSourceNoteStorage*)sharedStorage;
- (BOOL)ensureDB;




@end

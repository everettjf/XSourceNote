//
//  XSNote.h
//  XSourceNote
//
//  Created by everettjf on 16/3/7.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class XSourceNoteIndex;
NS_ASSUME_NONNULL_BEGIN

@interface XSNote : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(XSourceNoteIndex*)noteIndex;

-(NSString*) title;

@end

NS_ASSUME_NONNULL_END

#import "XSNote+CoreDataProperties.h"

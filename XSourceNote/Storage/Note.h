//
//  Note.h
//  XSourceNote
//
//  Created by everettjf on 16/2/29.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class XSourceNoteIndex;
@interface Note : NSManagedObject

-(XSourceNoteIndex*)noteIndex;

@end

NS_ASSUME_NONNULL_END

#import "Note+CoreDataProperties.h"

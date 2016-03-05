//
//  Note+CoreDataProperties.h
//  XSourceNote
//
//  Created by everettjf on 16/3/5.
//  Copyright © 2016年 everettjf. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *extension;
@property (nullable, nonatomic, retain) NSNumber *lineNumberBegin;
@property (nullable, nonatomic, retain) NSNumber *lineNumberEnd;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *pathLocal;
@property (nullable, nonatomic, retain) NSString *pathRelative;
@property (nullable, nonatomic, retain) NSString *tag;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSString *uniqueID;

@end

NS_ASSUME_NONNULL_END

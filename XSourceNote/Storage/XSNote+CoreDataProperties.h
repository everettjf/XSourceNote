//
//  XSNote+CoreDataProperties.h
//  XSourceNote
//
//  Created by everettjf on 16/3/12.
//  Copyright © 2016年 everettjf. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "XSNote.h"

NS_ASSUME_NONNULL_BEGIN

@interface XSNote (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *extension;
@property (nullable, nonatomic, retain) NSNumber *begin;
@property (nullable, nonatomic, retain) NSNumber *end;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *localPath;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *tag;
@property (nullable, nonatomic, retain) NSString *uniqueID;
@property (nullable, nonatomic, retain) NSDate *updatedAt;

@end

NS_ASSUME_NONNULL_END

//
//  XSStore+CoreDataProperties.h
//  XSourceNote
//
//  Created by everettjf on 16/3/7.
//  Copyright © 2016年 everettjf. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "XSStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface XSStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSString *value;

@end

NS_ASSUME_NONNULL_END

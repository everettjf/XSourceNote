//
//  Note+CoreDataProperties.m
//  XSourceNote
//
//  Created by everettjf on 16/2/29.
//  Copyright © 2016年 everettjf. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note+CoreDataProperties.h"

@implementation Note (CoreDataProperties)

@dynamic createdAt;
@dynamic updatedAt;
@dynamic pathLocal;
@dynamic pathRelative;
@dynamic lineNumberEnd;
@dynamic lineNumberBegin;
@dynamic content;
@dynamic extension;
@dynamic order;
@dynamic tag;

@end

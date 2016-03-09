//
//  XSourceNoteFormatter.h
//  XSourceNote
//
//  Created by everettjf on 16/3/9.
//  Copyright © 2016年 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XSourceNoteFormatter : NSObject


+ (XSourceNoteFormatter*)sharedFormatter;

- (BOOL)saveTo:(NSString*)filePath;

@end

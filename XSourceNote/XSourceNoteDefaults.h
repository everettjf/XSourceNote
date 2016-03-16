//
//  XSourceNoteDefaults.h
//  XSourceNote
//
//  Created by everettjf on 10/31/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shortcut.h"

@interface XSourceNoteDefaults : NSObject <NSCoding>

+(XSN_MAXShortcut*)defaultShortcutToggle;
+(XSN_MAXShortcut*)defaultShortcutShow;

+(XSourceNoteDefaults*)sharedDefaults;

@property (nonatomic,strong) XSN_MAXShortcut* currentShortcutToggle;
@property (nonatomic,strong) XSN_MAXShortcut* currentShortcutShow;

@property (nonatomic,strong) NSMenuItem *toggleMenuItem;
@property (nonatomic,strong) NSMenuItem *showMenuItem;

@property (nonatomic,assign) NSNumber *codeStyle; // 0 ``` , 1 {% highlight ....

-(void)enableAllMenuShortcuts:(BOOL)enable;

-(void)synchronize;

@end

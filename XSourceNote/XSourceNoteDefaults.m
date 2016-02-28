//
//  XSourceNoteDefaults.m
//  XSourceNote
//
//  Created by everettjf on 10/31/15.
//  Copyright © 2015 everettjf. All rights reserved.
//

#import "XSourceNoteDefaults.h"
#import "XSourceNoteUtil.h"

static NSString * const kXSourceNoteDefaultsShortcutToggle = @"XSourceNoteDefaultsShortcutToggle";
static NSString * const kXSourceNoteDefaultsShortcutNext = @"XSourceNoteDefaultsShortcutNext";
static NSString * const kXSourceNoteDefaultsShortcutPrev = @"XSourceNoteDefaultsShortcutPrev";
static NSString * const kXSourceNoteDefaultsShortcutShow = @"XSourceNoteDefaultsShortcutShow";

@implementation XSourceNoteDefaults

+(MASShortcut *)defaultShortcutToggle{
    return [MASShortcut shortcutWithKeyCode:kVK_F4 modifierFlags:NSCommandKeyMask];
}
+(MASShortcut *)defaultShortcutShow{
    return [MASShortcut shortcutWithKeyCode:kVK_F4 modifierFlags:NSShiftKeyMask];
}

+(XSourceNoteDefaults *)sharedDefaults{
    static XSourceNoteDefaults *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [NSKeyedUnarchiver unarchiveObjectWithFile:[XSourceNoteDefaults configFilePath]];
        if(inst == nil){
            inst = [[XSourceNoteDefaults alloc]init];
        }
    });
    return inst;
}

+(NSString*)configFilePath{
    return [[XSourceNoteUtil settingDirectory]stringByAppendingPathComponent:@"config"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentShortcutToggle = [XSourceNoteDefaults defaultShortcutToggle];
        self.currentShortcutShow = [XSourceNoteDefaults defaultShortcutShow];
    }
    return self;
}

-(void)synchronize{
    [NSKeyedArchiver archiveRootObject:self toFile:[XSourceNoteDefaults configFilePath]];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.currentShortcutToggle = [aDecoder decodeObjectForKey:kXSourceNoteDefaultsShortcutToggle];
        self.currentShortcutShow = [aDecoder decodeObjectForKey:kXSourceNoteDefaultsShortcutShow];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.currentShortcutToggle forKey:kXSourceNoteDefaultsShortcutToggle];
    [aCoder encodeObject:self.currentShortcutShow forKey:kXSourceNoteDefaultsShortcutShow];
}

-(void)enableAllMenuShortcuts:(BOOL)enable{
    if(enable){
        self.toggleMenuItem.keyEquivalent = self.currentShortcutToggle.keyCodeStringForKeyEquivalent;
        self.toggleMenuItem.keyEquivalentModifierMask = self.currentShortcutToggle.modifierFlags;
        
        self.showMenuItem.keyEquivalent = self.currentShortcutShow.keyCodeStringForKeyEquivalent;
        self.showMenuItem.keyEquivalentModifierMask = self.currentShortcutShow.modifierFlags;
    }else{
        NSArray *menus = @[
                           self.toggleMenuItem,
                           self.showMenuItem
                           ];
        for (NSMenuItem *menu in menus){
            menu.keyEquivalent = @"";
            menu.keyEquivalentModifierMask = 0;
        }
    }
}

@end

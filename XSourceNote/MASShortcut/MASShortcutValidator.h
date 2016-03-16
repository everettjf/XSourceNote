#import "MASShortcut.h"

@interface XSN_MAXShortcutValidator : NSObject

// The following API enable hotkeys with the Option key as the only modifier
// For example, Option-G will not generate © and Option-R will not paste ®
@property(assign) BOOL allowAnyShortcutWithOptionModifier;

+ (instancetype) sharedValidator;

- (BOOL) isShortcutValid: (XSN_MAXShortcut*) shortcut;
- (BOOL) isShortcut: (XSN_MAXShortcut*) shortcut alreadyTakenInMenu: (NSMenu*) menu explanation: (NSString**) explanation;
- (BOOL) isShortcutAlreadyTakenBySystem: (XSN_MAXShortcut*) shortcut explanation: (NSString**) explanation;

@end

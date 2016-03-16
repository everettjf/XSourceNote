#import "MASShortcut.h"

/**
 Executes action when a shortcut is pressed.

 There can only be one instance of this class, otherwise things
 will probably not work. (There’s a Carbon event handler inside
 and there can only be one Carbon event handler of a given type.)
*/
@interface XSN_MAXShortcutMonitor : NSObject

- (instancetype) init __unavailable;
+ (instancetype) sharedMonitor;

/**
 Register a shortcut along with an action.

 Attempting to insert an already registered shortcut probably won’t work.
 It may burn your house or cut your fingers. You have been warned.
*/
- (BOOL) registerShortcut: (XSN_MAXShortcut*) shortcut withAction: (dispatch_block_t) action;
- (BOOL) isShortcutRegistered: (XSN_MAXShortcut*) shortcut;

- (void) unregisterShortcut: (XSN_MAXShortcut*) shortcut;
- (void) unregisterAllShortcuts;

@end

#import "MASShortcut.h"

extern FourCharCode const XSN_MAXHotKeySignature;

@interface XSN_MAXHotKey : NSObject

@property(readonly) UInt32 carbonID;
@property(copy) dispatch_block_t action;

+ (instancetype) registeredHotKeyWithShortcut: (XSN_MAXShortcut*) shortcut;

@end

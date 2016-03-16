#import "MASHotKey.h"

FourCharCode const XSN_MAXHotKeySignature = 'MASS';

@interface XSN_MAXHotKey ()
@property(assign) EventHotKeyRef hotKeyRef;
@property(assign) UInt32 carbonID;
@end

@implementation XSN_MAXHotKey

- (instancetype) initWithShortcut: (XSN_MAXShortcut*) shortcut
{
    self = [super init];

    static UInt32 CarbonHotKeyID = 0;

    _carbonID = ++CarbonHotKeyID;
    EventHotKeyID hotKeyID = { .signature = XSN_MAXHotKeySignature, .id = _carbonID };

    OSStatus status = RegisterEventHotKey([shortcut carbonKeyCode], [shortcut carbonFlags],
        hotKeyID, GetEventDispatcherTarget(), 0, &_hotKeyRef);

    if (status != noErr) {
        return nil;
    }

    return self;
}

+ (instancetype) registeredHotKeyWithShortcut: (XSN_MAXShortcut*) shortcut
{
    return [[self alloc] initWithShortcut:shortcut];
}

- (void) dealloc
{
    if (_hotKeyRef) {
        UnregisterEventHotKey(_hotKeyRef);
        _hotKeyRef = NULL;
    }
}

@end

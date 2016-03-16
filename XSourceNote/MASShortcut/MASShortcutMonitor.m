#import "MASShortcutMonitor.h"
#import "MASHotKey.h"

@interface XSN_MAXShortcutMonitor ()
@property(assign) EventHandlerRef eventHandlerRef;
@property(strong) NSMutableDictionary *hotKeys;
@end

static OSStatus XSN_MAXCarbonEventCallback(EventHandlerCallRef, EventRef, void*);

@implementation XSN_MAXShortcutMonitor

#pragma mark Initialization

- (instancetype) init
{
    self = [super init];
    [self setHotKeys:[NSMutableDictionary dictionary]];
    EventTypeSpec hotKeyPressedSpec = { .eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed };
    OSStatus status = InstallEventHandler(GetEventDispatcherTarget(), XSN_MAXCarbonEventCallback,
        1, &hotKeyPressedSpec, (__bridge void*)self, &_eventHandlerRef);
    if (status != noErr) {
        return nil;
    }
    return self;
}

- (void) dealloc
{
    if (_eventHandlerRef) {
        RemoveEventHandler(_eventHandlerRef);
        _eventHandlerRef = NULL;
    }
}

+ (instancetype) sharedMonitor
{
    static dispatch_once_t once;
    static XSN_MAXShortcutMonitor *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Registration

- (BOOL) registerShortcut: (XSN_MAXShortcut*) shortcut withAction: (dispatch_block_t) action
{
    XSN_MAXHotKey *hotKey = [XSN_MAXHotKey registeredHotKeyWithShortcut:shortcut];
    if (hotKey) {
        [hotKey setAction:action];
        [_hotKeys setObject:hotKey forKey:shortcut];
        return YES;
    } else {
        return NO;
    }
}

- (void) unregisterShortcut: (XSN_MAXShortcut*) shortcut
{
    if (shortcut) {
        [_hotKeys removeObjectForKey:shortcut];
    }
}

- (void) unregisterAllShortcuts
{
    [_hotKeys removeAllObjects];
}

- (BOOL) isShortcutRegistered: (XSN_MAXShortcut*) shortcut
{
    return !![_hotKeys objectForKey:shortcut];
}

#pragma mark Event Handling

- (void) handleEvent: (EventRef) event
{
    if (GetEventClass(event) != kEventClassKeyboard) {
        return;
    }

    EventHotKeyID hotKeyID;
    OSStatus status = GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
    if (status != noErr || hotKeyID.signature != XSN_MAXHotKeySignature) {
        return;
    }

    [_hotKeys enumerateKeysAndObjectsUsingBlock:^(XSN_MAXShortcut *shortcut, XSN_MAXHotKey *hotKey, BOOL *stop) {
        if (hotKeyID.id == [hotKey carbonID]) {
            if ([hotKey action]) {
                dispatch_async(dispatch_get_main_queue(), [hotKey action]);
            }
            *stop = YES;
        }
    }];
}

@end

static OSStatus XSN_MAXCarbonEventCallback(EventHandlerCallRef _, EventRef event, void *context)
{
    XSN_MAXShortcutMonitor *dispatcher = (__bridge id)context;
    [dispatcher handleEvent:event];
    return noErr;
}

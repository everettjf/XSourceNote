@class XSN_MAXShortcut, XSN_MAXShortcutValidator;

extern NSString *const XSN_MAXShortcutBinding;

typedef enum {
    XSN_MAXShortcutViewStyleDefault = 0,  // Height = 19 px
    XSN_MAXShortcutViewStyleTexturedRect, // Height = 25 px
    XSN_MAXShortcutViewStyleRounded,      // Height = 43 px
    XSN_MAXShortcutViewStyleFlat
} XSN_MAXShortcutViewStyle;

@interface XSN_MAXShortcutView : NSView

@property (nonatomic, strong) XSN_MAXShortcut *shortcutValue;
@property (nonatomic, strong) XSN_MAXShortcutValidator *shortcutValidator;
@property (nonatomic, getter = isRecording) BOOL recording;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) void (^shortcutValueChange)(XSN_MAXShortcutView *sender);
@property (nonatomic, assign) XSN_MAXShortcutViewStyle style;

/// Returns custom class for drawing control.
+ (Class)shortcutCellClass;

- (void)setAcceptsFirstResponder:(BOOL)value;

@end

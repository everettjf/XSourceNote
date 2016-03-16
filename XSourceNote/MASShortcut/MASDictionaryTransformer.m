#import "MASDictionaryTransformer.h"
#import "MASShortcut.h"

NSString *const XSN_MAXDictionaryTransformerName = @"MASDictionaryTransformer";

static NSString *const XSN_MAXKeyCodeKey = @"keyCode";
static NSString *const XSN_MAXModifierFlagsKey = @"modifierFlags";

@implementation XSN_MAXDictionaryTransformer

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

// Storing nil values as an empty dictionary lets us differ between
// “not available, use default value” and “explicitly set to none”.
// See http://stackoverflow.com/questions/5540760 for details.
- (NSDictionary*) reverseTransformedValue: (XSN_MAXShortcut*) shortcut
{
    if (shortcut == nil) {
        return [NSDictionary dictionary];
    } else {
        return @{
            XSN_MAXKeyCodeKey: @([shortcut keyCode]),
            XSN_MAXModifierFlagsKey: @([shortcut modifierFlags])
        };
    }
}

- (XSN_MAXShortcut*) transformedValue: (NSDictionary*) dictionary
{
    // We have to be defensive here as the value may come from user defaults.
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    id keyCodeBox = [dictionary objectForKey:XSN_MAXKeyCodeKey];
    id modifierFlagsBox = [dictionary objectForKey:XSN_MAXModifierFlagsKey];

    SEL integerValue = @selector(integerValue);
    if (![keyCodeBox respondsToSelector:integerValue] || ![modifierFlagsBox respondsToSelector:integerValue]) {
        return nil;
    }

    return [XSN_MAXShortcut
        shortcutWithKeyCode:[keyCodeBox integerValue]
        modifierFlags:[modifierFlagsBox integerValue]];
}

@end

#import "MASShortcutView+Bindings.h"

@implementation XSN_MAXShortcutView (Bindings)

- (NSString*) associatedUserDefaultsKey
{
    NSDictionary* bindingInfo = [self infoForBinding:XSN_MAXShortcutBinding];
    if (bindingInfo != nil) {
        NSString *keyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
        NSString *key = [keyPath stringByReplacingOccurrencesOfString:@"values." withString:@""];
        return key;
    } else {
        return nil;
    }
}

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey withTransformer: (NSValueTransformer*) transformer
{
    // Break previous binding if any
    NSString *currentKey = [self associatedUserDefaultsKey];
    if (currentKey != nil) {
        [self unbind:currentKey];
    }

    // Stop if the new binding is nil
    if (newKey == nil) {
        return;
    }

    NSDictionary *options = transformer ?
        @{NSValueTransformerBindingOption:transformer} :
        nil;

    [self bind:XSN_MAXShortcutBinding
        toObject:[NSUserDefaultsController sharedUserDefaultsController]
        withKeyPath:[@"values." stringByAppendingString:newKey]
        options:options];
}

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey withTransformerName: (NSString*) transformerName
{
    [self setAssociatedUserDefaultsKey:newKey withTransformer:[NSValueTransformer valueTransformerForName:transformerName]];
}

- (void) setAssociatedUserDefaultsKey: (NSString*) newKey
{
    [self setAssociatedUserDefaultsKey:newKey withTransformerName:NSKeyedUnarchiveFromDataTransformerName];
}

@end

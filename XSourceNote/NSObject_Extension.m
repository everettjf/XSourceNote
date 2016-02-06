//
//  NSObject_Extension.m
//  XSourceNote
//
//  Created by everettjf on 16/2/6.
//  Copyright © 2016年 everettjf. All rights reserved.
//


#import "NSObject_Extension.h"
#import "XSourceNote.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[XSourceNote alloc] initWithBundle:plugin];
        });
    }
}
@end

//
//  DWKWebViewEvent.m
//  dsbridge
//
//  Created by mayong on 2025/7/1.
//  Copyright © 2025 杜文. All rights reserved.
//

#import "DWKObjects.h"

@implementation DWKWebViewEvent

+ (instancetype)dwk_eventWithNamespace:(NSString *)dwk_namespace
                                method:(NSString *)dwk_method
                                  args:(id)dwk_args
{
   return [self dwk_eventWithNamespace:dwk_namespace
                                method:dwk_method
                                  args:dwk_args
                              callback:nil];
}

+ (instancetype)dwk_eventWithNamespace:(NSString *)dwk_namespace
                                method:(NSString *)dwk_method
                                  args:(id)dwk_args
                              callback:(DWKEventCallback)dwk_callback
{
    DWKWebViewEvent *dwk_event = [[DWKWebViewEvent alloc] init];
    dwk_event.dwk_namespace = dwk_namespace;
    dwk_event.dwk_method = dwk_method;
    dwk_event.dwk_args = dwk_args;
    dwk_event.dwk_callback = dwk_callback;
    return dwk_event;
}

@end

@implementation DWKCallInfo

+ (instancetype)dwk_callInfoWithMethod:(NSString *)dwk_method
                                dwk_id:(NSNumber *)dwk_id
                              dwk_args:(NSArray *)dwk_args
{
    DWKCallInfo *dwk_callInfo = [[DWKCallInfo alloc] init];
    dwk_callInfo.dwk_method = dwk_method;
    dwk_callInfo.dwk_id = dwk_id;
    dwk_callInfo.dwk_args = dwk_args;
    return dwk_callInfo;
}

@end

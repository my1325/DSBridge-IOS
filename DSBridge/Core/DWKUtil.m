//
//  Util.m
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <objc/runtime.h>
#import "DWKUtil.h"
#import "DWKObjects.h"
#import <objc/message.h>
#import <objc/runtime.h>

inline DWKWebViewEvent * dwk_event_with_origin(NSString *dwk_originString, id dwk_args) {
    return dwk_event_with_origin_handler(dwk_originString, dwk_args, nil);
}

inline DWKWebViewEvent * dwk_event_with_origin_handler(NSString *dwk_originString, id dwk_args, DWKEventCallback dwk_callback) {
    // 参数验证
    if (!dwk_originString.length) {
        return [DWKWebViewEvent dwk_eventWithNamespace:@""
                                                method:@""
                                                  args:dwk_args];
    }

    // 去除首尾空白字符
    dwk_originString = [dwk_originString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 查找最后一个点的位置
    NSRange dwk_range = [dwk_originString rangeOfString:@"." options:NSBackwardsSearch];
    NSString *dwk_namespace = @"";
    NSString *dwk_method = dwk_originString; // 默认整个字符串作为方法名

    if (dwk_range.location != NSNotFound) {
        if (dwk_range.location > 0) {
            // 正常情况：namespace.method
            dwk_namespace = [dwk_originString substringToIndex:dwk_range.location];
            dwk_method = [dwk_originString substringFromIndex:dwk_range.location + 1];
        } else {
            // 特殊情况：.method (点在开头)
            dwk_namespace = @"";
            dwk_method = [dwk_originString substringFromIndex:1]; // 跳过开头的点
        }
    }

    return [DWKWebViewEvent dwk_eventWithNamespace:dwk_namespace
                                            method:dwk_method
                                              args:dwk_args
                                          callback:dwk_callback];
}

inline NSString * dwk_to_json_string(id dwk_object) {
    NSString *dwk_jsonString = nil;
    NSError *dwk_error;

    if (![NSJSONSerialization isValidJSONObject:dwk_object]) {
        return @"{}";
    }

    NSData *dkw_jsonData = [NSJSONSerialization dataWithJSONObject:dwk_object options:0 error:&dwk_error];

    if (!dkw_jsonData) {
        return @"{}";
    } else {
        dwk_jsonString = [[NSString alloc] initWithData:dkw_jsonData encoding:NSUTF8StringEncoding];
    }

    return dwk_jsonString;
}

inline NSDictionary * dwk_to_json_object(NSString *dwk_json_string) {
    if (dwk_json_string == nil) {
        return @{};
    }

    NSData *dwk_jsonData = [dwk_json_string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *dwk_err;
    NSDictionary *dwk_dic = [NSJSONSerialization JSONObjectWithData:dwk_jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&dwk_err];

    if (!dwk_err) {
        return dwk_dic;
    }

#if DEBUG
    NSLog(@"json解析失败：%@", dwk_err);
#endif

    return @{};
}


NSSet<NSString *> * _Nonnull dwk_method_list_for_class(Class _Nonnull dwk_class) {
    NSMutableSet *dwk_methodSet = [NSMutableSet set];
    Class dwk_cls = dwk_class;
    while (dwk_cls && dwk_cls != [NSObject class]) {
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(dwk_cls, &methodCount);

        for (unsigned int i = 0; i < methodCount; i++) {
            SEL selector = method_getName(methods[i]);
            NSString *methodName = NSStringFromSelector(selector);
            // Add the method name to the set
            [dwk_methodSet addObject:methodName];
        }

        free(methods);
        // Move to the superclass
        dwk_cls = class_getSuperclass(dwk_cls);
    }
    
    return [dwk_methodSet copy];
}

id _Nullable dwk_invoke_method(id _Nonnull dwk_target, SEL _Nonnull dwk_selector, NSArray *_Nullable dwk_args) {
    Method method1 = class_getInstanceMethod([dwk_target class], dwk_selector);
    char retType[10];
    method_getReturnType(method1, retType, 10);

    if (strcmp("v", retType) == 0) {
        void (*dwk_action)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
        dwk_action(dwk_target, dwk_selector, dwk_args);
        return nil;
    } else {
        id (*dwk_action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
        id dwk_ret = dwk_action(dwk_target, dwk_selector, dwk_args);
        return dwk_ret;
    }
}

extern void dwk_invoke_method_with_callback(id _Nonnull dwk_target, SEL _Nonnull dwk_selector, NSArray *_Nullable dwk_args, void (^_Nullable dwk_callback)(id _Nullable, BOOL)) {
    void (*dwk_action)(id, SEL, id, id) = (void (*)(id, SEL, id, id))objc_msgSend;
    dwk_action(dwk_target, dwk_selector, dwk_args, dwk_callback);
}

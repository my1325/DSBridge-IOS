//
//  Util.m
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <objc/runtime.h>
//#import "DWKWebView.h"
#import "DWKUtil.h"


//@implementation JSBUtil
//+ (NSString *)objToJsonString:(id)dict
//{
//    NSString *jsonString = nil;
//    NSError *error;
//
//    if (![NSJSONSerialization isValidJSONObject:dict]) {
//        return @"{}";
//    }
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//
//    if (!jsonData) {
//        return @"{}";
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//
//    return jsonString;
//}
//
////get this class all method
// + (NSArray *)allMethodFromClass:(Class)class {
//    NSMutableArray *methods = [NSMutableArray array];

//    while (class) {
//        unsigned int count = 0;
//        Method *method = class_copyMethodList(class, &count);

//        for (unsigned int i = 0; i < count; i++) {
//            SEL name1 = method_getName(method[i]);
//            const char *selName = sel_getName(name1);
//            NSString *strName = [NSString stringWithCString:selName encoding:NSUTF8StringEncoding];
//            [methods addObject:strName];
//        }

//        free(method);

//        Class cls = class_getSuperclass(class);
//        class = [NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])] ? nil : cls;
//    }

//    return [NSArray arrayWithArray:methods];
// }

// //return method name for xxx: or xxx:handle:
// + (NSString *)methodByNameArg:(NSInteger)argNum selName:(NSString *)selName class:(Class)class
// {
//     if (!class || !selName) {
//         return nil;
//     }

//     NSArray *methods = [JSBUtil allMethodFromClass:class];
//     NSInteger expectedColonCount = argNum;

//     for (NSString *method in methods) {
//         // 快速检查：如果方法名不是以selName开头，直接跳过
//         if (![method hasPrefix:selName]) {
//             continue;
//         }

//         // 计算冒号个数来判断参数个数
//         NSInteger colonCount = [method componentsSeparatedByString:@":"].count - 1;

//         if (colonCount == expectedColonCount) {
//             // 进一步验证方法名前缀是否完全匹配
//             if (colonCount == 0) {
//                 // 无参数方法，直接比较整个方法名
//                 if ([method isEqualToString:selName]) {
//                     return method;
//                 }
//             } else {
//                 // 有参数方法，提取方法名前缀比较
//                 NSRange firstColonRange = [method rangeOfString:@":"];
//                 if (firstColonRange.location != NSNotFound) {
//                     NSString *methodPrefix = [method substringToIndex:firstColonRange.location];
//                     if ([methodPrefix isEqualToString:selName]) {
//                         return method;
//                     }
//                 }
//             }
//         }
//     }

//     return nil;
// }
//
//+ (NSArray *)parseNamespace:(NSString *)method {
//    NSRange range = [method rangeOfString:@"." options:NSBackwardsSearch];
//    NSString *namespace = @"";
//
//    if (range.location != NSNotFound) {
//        namespace = [method substringToIndex:range.location];
//        method = [method substringFromIndex:range.location + 1];
//    }
//
//    return @[namespace, method];
//}
//
//+ (id)jsonStringToObject:(NSString *)jsonString
//{
//    if (jsonString == nil) {
//        return nil;
//    }
//
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&err];
//
//    if (err) {
//        NSLog(@"json解析失败：%@", err);
//        return nil;
//    }
//
//    return dic;
//}
//
//@end

#import "DWKObjects.h"

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

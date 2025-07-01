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
//+ (NSArray *)allMethodFromClass:(Class)class {
//    NSMutableArray *methods = [NSMutableArray array];
//
//    while (class) {
//        unsigned int count = 0;
//        Method *method = class_copyMethodList(class, &count);
//
//        for (unsigned int i = 0; i < count; i++) {
//            SEL name1 = method_getName(method[i]);
//            const char *selName = sel_getName(name1);
//            NSString *strName = [NSString stringWithCString:selName encoding:NSUTF8StringEncoding];
//            [methods addObject:strName];
//        }
//
//        free(method);
//
//        Class cls = class_getSuperclass(class);
//        class = [NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])] ? nil : cls;
//    }
//
//    return [NSArray arrayWithArray:methods];
//}
//
////return method name for xxx: or xxx:handle:
//+ (NSString *)methodByNameArg:(NSInteger)argNum selName:(NSString *)selName class:(Class)class
//{
//    NSString *result = nil;
//
//    if (class) {
//        NSArray *arr = [JSBUtil allMethodFromClass:class];
//
//        for (int i = 0; i < arr.count; i++) {
//            NSString *method = arr[i];
//            NSArray *tmpArr = [method componentsSeparatedByString:@":"];
//            NSRange range = [method rangeOfString:@":"];
//
//            if (range.length > 0) {
//                NSString *methodName = [method substringWithRange:NSMakeRange(0, range.location)];
//
//                if ([methodName isEqualToString:selName] && tmpArr.count == (argNum + 1)) {
//                    result = method;
//                    return result;
//                }
//            }
//        }
//    }
//
//    return result;
//}
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

inline DWKWebViewEvent * dwk_event_with_origin(NSString *dwk_originString, NSString *dwk_argsString) {
    dwk_originString = [dwk_originString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange dwk_range = [dwk_originString rangeOfString:@"." options:NSBackwardsSearch];
    NSString *dwk_method = @"";
    NSString *dwk_namespace = @"";

    if (dwk_range.location != NSNotFound) {
        dwk_namespace = [dwk_originString substringToIndex:dwk_range.location];
        dwk_method = [dwk_originString substringFromIndex:dwk_range.location + 1];
    }

    return [DWKWebViewEvent dwk_eventWithNamespace:dwk_namespace
                                            method:dwk_method
    args:dwk_to_json_object(dwk_argsString)];
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

    if (!dwk_err) return dwk_dic;

#if DEBUG
    NSLog(@"json解析失败：%@", dwk_err);
#endif

    return @{};
}

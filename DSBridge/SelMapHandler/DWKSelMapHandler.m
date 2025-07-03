//
//  DWKSelMapHandler.m
//  dsbridge
//
//  Created by mayong on 2025/7/2.
//  Copyright © 2025 杜文. All rights reserved.
//

#import "DWKObjects.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "DWKSelMapHandler.h"
#import "DWKWebView.h"

//@interface DWKNamespaceObject : NSObject
//
//@property (nonatomic, copy) DWKNamespace dwk_namespace;
//
//@property (nonatomic, strong) id dwk_object;
//
//+ (instancetype)dwk_namespaceObjectWithNamespace:(DWKNamespace)dwk_namespace
//                                          object:(id)object;
//
//- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
//               hasCompletion:(BOOL)dwk_hasCompletion;
//
//- (id)dwk_invokeWithSelector:(NSString *)dwk_selectorName
//                   arguments:(NSArray *)arguments
//           completionHandler:(void (^)(id, BOOL))completionHandler;
//
//@end
//
//@implementation DWKNamespaceObject {
//    NSMutableSet *dwk_methodSet;
//}
//
//+ (instancetype)dwk_namespaceObjectWithNamespace:(DWKNamespace)dwk_namespace object:(id)object {
//    DWKNamespaceObject *namespaceObject = [[DWKNamespaceObject alloc] init];
//
//    namespaceObject.dwk_namespace = dwk_namespace;
//    namespaceObject.dwk_object = object;
//    return namespaceObject;
//}
//
//- (void)setDwk_object:(id)dwk_object {
//    dwk_methodSet = [NSMutableSet set];
//
//    if (!dwk_object) {
//        NSLog(@"Warning: Attempted to set a nil object for namespace '%@'.", self.dwk_namespace);
//        return;
//    }
//
//    _dwk_object = dwk_object;
//
//    // Dynamically fetch methods from the object and store them in the map
//    Class dwk_cls = [dwk_object class];
//
//    while (dwk_cls && dwk_cls != [NSObject class]) {
//        unsigned int methodCount = 0;
//        Method *methods = class_copyMethodList([self.dwk_object class], &methodCount);
//
//        for (unsigned int i = 0; i < methodCount; i++) {
//            SEL selector = method_getName(methods[i]);
//            NSString *methodName = NSStringFromSelector(selector);
//
//            if (!methodName.length) {
//                continue;
//            }
//
//            // Add the method name to the set
//            [dwk_methodSet addObject:methodName];
//        }
//
//        free(methods);
//
//        // Move to the superclass
//        dwk_cls = class_getSuperclass(dwk_cls);
//    }
//}
//
//- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
//               hasCompletion:(BOOL)dwk_hasCompletion {
//    if (!dwk_methodName.length || !self.dwk_object) {
//        return nil;
//    }
//
//    // Check if the method exists in the method set
//    NSString * dwk_retSelector = nil;
//
//    for (NSString *dwk_selectorString in dwk_methodSet) {
//        if (!dwk_selectorString.length || ![dwk_selectorString hasPrefix:dwk_methodName]) {
//            continue;
//        }
//
//        // Check if the method matches the expected format
//        NSInteger dwk_colonCount = [dwk_selectorString componentsSeparatedByString:@":"].count - 1;
//
//        if (!dwk_hasCompletion || dwk_colonCount == 2) {
//            // no completion
//            dwk_retSelector = dwk_selectorString;
//            break;
//        }
//    }
//    
//    if (!dwk_retSelector.length) return nil;
//    
//    SEL dwk_resultSelector = NSSelectorFromString(dwk_retSelector);
//
//    if (![_dwk_object respondsToSelector:dwk_resultSelector]) {
//        NSLog(@"Warning: Object '%@' does not respond to selector '%@'.", self.dwk_object, dwk_retSelector);
//        return nil;
//    }
//    
//    return dwk_resultSelector;
//}
//
//- (id)dwk_invokeWithSelector:(NSString *)dwk_selectorName
//                   arguments:(NSArray *)arguments
//           completionHandler:(void (^)(id, BOOL))completionHandler {
//    SEL dwk_selector = [self dwk_selectorForMethod:dwk_selectorName hasCompletion:completionHandler != nil];
//
//    if (!dwk_selector) {
//        if (completionHandler) completionHandler(nil, NO);
//        return nil;
//    }
//    
//    if (!completionHandler) {
//        void (*dwk_action)(id, SEL, id, id) = (void (*)(id, SEL, id, id))objc_msgSend;
//        dwk_action(_dwk_object, dwk_selector, arguments, completionHandler);
//        return nil;
//    }
//
//    Method method1 = class_getInstanceMethod([_dwk_object class], dwk_selector);
//    char retType[10];
//    method_getReturnType(method1, retType, 10);
//
//    if (strcmp("v", retType) == 0) {
//        void (*dwk_action)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
//        dwk_action(_dwk_object, dwk_selector, arguments);
//        return nil;
//    } else {
//        id (*dwk_action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
//        id dwk_ret = dwk_action(_dwk_object, dwk_selector, arguments);
//        return dwk_ret;
//    }
//}
//
//@end

@implementation DWKSelMapHandler {
    NSMutableDictionary *dwk_selMap;
    NSObject *dwk_target;
    NSMutableSet *dwk_selectorSet;
}

+ (instancetype)dwk_handlerWithTarget:(id)dwk_target selMap:(NSDictionary *)dwk_selMap {
    DWKSelMapHandler *handler = [[DWKSelMapHandler alloc] init];
    [handler dwk_setSelMap:dwk_selMap];
    [handler dwk_setTarget:dwk_target];
    [handler dwk_handleMapSel];
    return handler;
}

- (id)dwk_target {
    // Return a copy of the target object
    return dwk_target;
}

- (NSDictionary *)dwk_selMap {
    // Return a copy of the selMap dictionary
    return [dwk_selMap copy];
}

- (void)dwk_setTarget:(NSObject *)dwk_target {
    dwk_target = dwk_target;
}

- (void)dwk_setSelMap: (NSDictionary *)dwk_selMap {
    dwk_selMap = [NSMutableDictionary dictionaryWithDictionary:dwk_selMap];
}

- (void)dwk_handleMapSel {
    // Dynamically fetch methods from the object and store them in the map
    dwk_selectorSet = [NSMutableSet set];
    
    Class dwk_cls = [dwk_target class];

    while (dwk_cls && dwk_cls != [NSObject class]) {
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList([dwk_target class], &methodCount);

        for (unsigned int i = 0; i < methodCount; i++) {
            SEL selector = method_getName(methods[i]);
            NSString *methodName = NSStringFromSelector(selector);

            if (!methodName.length) {
                continue;
            }

            // Add the method name to the set
            [dwk_selectorSet addObject:methodName];
        }

        free(methods);

        // Move to the superclass
        dwk_cls = class_getSuperclass(dwk_cls);
    }
}

- (BOOL)dwk_webView:(DWKWebView *)webView canHandleEvent:(DWKWebViewEvent *)eventName {
    NSString *dwk_mapSel = [NSString stringWithFormat:@"%@.%@", eventName.dwk_namespace, eventName.dwk_method];
    if (eventName.dwk_callback) {
        dwk_mapSel = [dwk_mapSel stringByAppendingString:@":"];
    }
    NSLog(@"%s: dwk_mapSel: %@", __FUNCTION__, dwk_mapSel);

    NSString *dwk_selectorName = dwk_selMap[dwk_mapSel];
    if (!dwk_selectorName.length || ![dwk_selectorSet containsObject:dwk_selectorName]) return NO;
    
    // Check if the selector name matches the expected format
    NSInteger dwk_colonCount = [dwk_selectorName componentsSeparatedByString:@":"].count - 1;
    if (!eventName.dwk_callback || dwk_colonCount >= 2) {
        return [dwk_target respondsToSelector:NSSelectorFromString(dwk_selectorName)];
    }
    
    return NO;
}

- (id)dwk_webView:(DWKWebView *)webView handleEvent:(DWKWebViewEvent *)eventName {
    NSString *dwk_mapSel = [NSString stringWithFormat:@"%@.%@", eventName.dwk_namespace, eventName.dwk_method];
    if (eventName.dwk_callback) {
        dwk_mapSel = [dwk_mapSel stringByAppendingString:@":"];
    }
    
    NSString *dwk_selectorName = dwk_selMap[dwk_mapSel];
    if (!dwk_selectorName.length || ![dwk_selectorSet containsObject:dwk_selectorName]) {
        return nil;
    }
    
    NSInteger dwk_colonCount = [dwk_selectorName componentsSeparatedByString:@":"].count - 1;
    if (dwk_colonCount < 2 && eventName.dwk_callback) {
        NSLog(@"Warning: Selector '%@' does not match expected format for callback.", dwk_selectorName);
        return nil;
    }
    
    SEL dwk_selector = NSSelectorFromString(dwk_selectorName);
    
    if (![dwk_target respondsToSelector:dwk_selector]) {
        NSLog(@"Warning: Target '%@' does not respond to selector '%@'.", dwk_target, dwk_selectorName);
        return nil;
    }
    
    // Prepare arguments
    NSArray *arguments = eventName.dwk_args ?: @[];
    
    // Invoke the method
    id result = nil;
    
    if (eventName.dwk_callback) {
        void (*action)(id, SEL, id, void (^)(id, BOOL)) = (void (*)(id, SEL, id, void (^)(id, BOOL)))objc_msgSend;
        action(dwk_target, dwk_selector, arguments, eventName.dwk_callback);
        return nil;
    }
    
    Method method1 = class_getInstanceMethod([dwk_target class], dwk_selector);
    char retType[10];
    method_getReturnType(method1, retType, 10);
    
    if (strcmp("v", retType) == 0) {
        void (*dwk_action)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
        dwk_action(dwk_target, dwk_selector, arguments);
        return nil;
    } else {
        id (*dwk_action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
        id dwk_ret = dwk_action(dwk_target, dwk_selector, arguments);
        return dwk_ret;
    }
    return result;
}

@end


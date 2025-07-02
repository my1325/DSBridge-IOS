//
//  DWKRunTimeHandler.m
//  dsbridge
//
//  Created by mayong on 2025/7/1.
//  Copyright © 2025 杜文. All rights reserved.
//

#import "DWKObjects.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "DWKRunTimeHandler.h"
#import "DWKWebView.h"

@interface DWKNamespaceObject : NSObject

@property (nonatomic, copy) DWKNamespace dwk_namespace;

@property (nonatomic, strong) id dwk_object;

+ (instancetype)dwk_namespaceObjectWithNamespace:(DWKNamespace)dwk_namespace
                                          object:(id)object;

- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
               hasCompletion:(BOOL)dwk_hasCompletion;

- (id)dwk_invokeWithSelector:(NSString *)dwk_selectorName
                   arguments:(NSArray *)arguments
           completionHandler:(void (^)(id, BOOL))completionHandler;

@end

@implementation DWKNamespaceObject {
    NSMutableSet *dwk_methodSet;
}

+ (instancetype)dwk_namespaceObjectWithNamespace:(DWKNamespace)dwk_namespace object:(id)object {
    DWKNamespaceObject *namespaceObject = [[DWKNamespaceObject alloc] init];

    namespaceObject.dwk_namespace = dwk_namespace;
    namespaceObject.dwk_object = object;
    return namespaceObject;
}

- (void)setDwk_object:(id)dwk_object {
    dwk_methodSet = [NSMutableSet set];

    if (!dwk_object) {
        NSLog(@"Warning: Attempted to set a nil object for namespace '%@'.", self.dwk_namespace);
        return;
    }

    _dwk_object = dwk_object;

    // Dynamically fetch methods from the object and store them in the map
    Class dwk_cls = [dwk_object class];

    while (dwk_cls && dwk_cls != [NSObject class]) {
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList([self.dwk_object class], &methodCount);

        for (unsigned int i = 0; i < methodCount; i++) {
            SEL selector = method_getName(methods[i]);
            NSString *methodName = NSStringFromSelector(selector);

            if (!methodName.length) {
                continue;
            }

            // Add the method name to the set
            [dwk_methodSet addObject:methodName];
        }

        free(methods);

        // Move to the superclass
        dwk_cls = class_getSuperclass(dwk_cls);
    }
}

- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
               hasCompletion:(BOOL)dwk_hasCompletion {
    if (!dwk_methodName.length || !self.dwk_object) {
        return nil;
    }

    // Check if the method exists in the method set
    NSString * dwk_retSelector = nil;

    for (NSString *dwk_selectorString in dwk_methodSet) {
        if (!dwk_selectorString.length || ![dwk_selectorString hasPrefix:dwk_methodName]) {
            continue;
        }

        // Check if the method matches the expected format
        NSInteger dwk_colonCount = [dwk_selectorString componentsSeparatedByString:@":"].count - 1;

        if (!dwk_hasCompletion || dwk_colonCount == 2) {
            // no completion
            dwk_retSelector = dwk_selectorString;
            break;
        }
    }
    
    if (!dwk_retSelector.length) return nil;
    
    SEL dwk_resultSelector = NSSelectorFromString(dwk_retSelector);

    if (![_dwk_object respondsToSelector:dwk_resultSelector]) {
        NSLog(@"Warning: Object '%@' does not respond to selector '%@'.", self.dwk_object, dwk_retSelector);
        return nil;
    }
    
    return dwk_resultSelector;
}

- (id)dwk_invokeWithSelector:(NSString *)dwk_selectorName
                   arguments:(NSArray *)arguments
           completionHandler:(void (^)(id, BOOL))completionHandler {
    SEL dwk_selector = [self dwk_selectorForMethod:dwk_selectorName hasCompletion:completionHandler != nil];

    if (!dwk_selector) {
        if (completionHandler) completionHandler(nil, NO);
        return nil;
    }
    
    if (!completionHandler) {
        void (*dwk_action)(id, SEL, id, id) = (void (*)(id, SEL, id, id))objc_msgSend;
        dwk_action(_dwk_object, dwk_selector, arguments, completionHandler);
        return nil;
    }

    Method method1 = class_getInstanceMethod([_dwk_object class], dwk_selector);
    char retType[10];
    method_getReturnType(method1, retType, 10);

    if (strcmp("v", retType) == 0) {
        void (*dwk_action)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
        dwk_action(_dwk_object, dwk_selector, arguments);
        return nil;
    } else {
        id (*dwk_action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
        id dwk_ret = dwk_action(_dwk_object, dwk_selector, arguments);
        return dwk_ret;
    }
}

@end

@implementation DWKRunTimeHandler {
    NSMutableDictionary *dwk_namespaceMap;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        dwk_namespaceMap = [NSMutableDictionary dictionary];
    }

    return self;
}

- (NSDictionary *)dwk_javascriptObjects {
    return [dwk_namespaceMap copy];
}

- (void)dwk_addJavascriptObject:(id)object forNamespace:(DWKNamespace)dwk_namespace {
    if (!object || !dwk_namespace) {
        return;
    }

    // Check if the object already exists for the namespace
    if (dwk_namespaceMap[dwk_namespace]) {
        NSLog(@"Warning: Namespace '%@' already exists. Overwriting the existing object.", dwk_namespace);
    }

    // Add or update the object for the given namespace
    dwk_namespaceMap[dwk_namespace] = [DWKNamespaceObject dwk_namespaceObjectWithNamespace:dwk_namespace object:object];
}

- (void)dwk_removeJavascriptObject:(DWKNamespace)dwk_namespace {
    if (!dwk_namespace || !dwk_namespaceMap[dwk_namespace]) {
        NSLog(@"Warning: Namespace '%@' does not exist. Cannot remove.", dwk_namespace);
        return;
    }

    [dwk_namespaceMap removeObjectForKey:dwk_namespace];
}

- (BOOL)dwk_webView:(DWKWebView *)webView canHandleEvent:(DWKWebViewEvent *)eventName {
    DWKNamespaceObject *namespaceObject = dwk_namespaceMap[eventName.dwk_namespace];
    if (!namespaceObject) {
        NSLog(@"Warning: Namespace '%@' does not exist.", eventName.dwk_namespace);
        return NO;
    }
    SEL dwk_selector = [namespaceObject dwk_selectorForMethod:eventName.dwk_method hasCompletion:eventName.dwk_callback != nil];
    if (!dwk_selector) {
        NSLog(@"Warning: Method '%@' in namespace '%@' does not exist.", eventName.dwk_method, eventName.dwk_namespace);
        return NO;
    }
    return YES;
}

- (id)dwk_webView:(DWKWebView *)webView handleEvent:(DWKWebViewEvent *)eventName {
    DWKNamespaceObject *namespaceObject = dwk_namespaceMap[eventName.dwk_namespace];
    if (!namespaceObject) {
        NSLog(@"Warning: Namespace '%@' does not exist.", eventName.dwk_namespace);
        return nil;
    }

    // Invoke the method with the provided arguments
    return [namespaceObject dwk_invokeWithSelector:eventName.dwk_method
                                          arguments:eventName.dwk_args
                                  completionHandler:eventName.dwk_callback];
}

@end

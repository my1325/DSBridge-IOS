//
//  DWKRunTimeHandler.m
//  dsbridge
//
//  Created by mayong on 2025/7/1.
//  Copyright © 2025 杜文. All rights reserved.
//

#import "DWKUtil.h"
#import "DWKObjects.h"
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
    NSSet *dwk_methodSet;
}

+ (instancetype)dwk_namespaceObjectWithNamespace:(DWKNamespace)dwk_namespace object:(id)object {
    DWKNamespaceObject *namespaceObject = [[DWKNamespaceObject alloc] init];

    namespaceObject.dwk_namespace = dwk_namespace;
    namespaceObject.dwk_object = object;
    return namespaceObject;
}

- (void)setDwk_object:(id)dwk_object {
    if (!dwk_object) {
        DWKLog(@"Warning: Attempted to set a nil object for namespace '%@'.", self.dwk_namespace);
        return;
    }

    _dwk_object = dwk_object;
    dwk_methodSet = dwk_method_list_for_class([dwk_object class]);
}

- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
               hasCompletion:(BOOL)dwk_hasCompletion {
    DWKLog(@"dwk_methodName: %@", dwk_methodName);
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

        if (!dwk_hasCompletion || dwk_colonCount >= 2) {
            // no completion
            dwk_retSelector = dwk_selectorString;
            break;
        }
    }
    
    if (!dwk_retSelector.length) return nil;
    
    SEL dwk_resultSelector = NSSelectorFromString(dwk_retSelector);

    if (![_dwk_object respondsToSelector:dwk_resultSelector]) {
        DWKLog(@"Warning: Object '%@' does not respond to selector '%@'.", self.dwk_object, dwk_retSelector);
        return nil;
    }
    
    return dwk_resultSelector;
}

- (id)dwk_invokeWithSelector:(NSString *)dwk_selectorName
                   arguments:(NSArray *)arguments
           completionHandler:(void (^)(id, BOOL))completionHandler {
    DWKLog(@"dwk_methodName: %@", dwk_selectorName);

    SEL dwk_selector = [self dwk_selectorForMethod:dwk_selectorName hasCompletion:completionHandler != nil];
    if (!dwk_selector) {
        if (completionHandler) completionHandler(nil, NO);
        return nil;
    }
    
    id args = arguments ?: @[];
    NSInteger dwk_colonCount = [NSStringFromSelector(dwk_selector) componentsSeparatedByString:@":"].count - 1;

    if (dwk_colonCount >= 2) {
        id dwk_callback = completionHandler ?: ^(id result, BOOL success) {
            // Default completion handler if none provided
            DWKLog(@"Default completion handler called with result: %@, success: %d", result, success);
        };
        
        dwk_invoke_method_with_callback(_dwk_object, dwk_selector, arguments, dwk_callback);
        return nil;
    }

    return dwk_invoke_method(_dwk_object, dwk_selector, arguments);
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
        DWKLog(@"Warning: Namespace '%@' already exists. Overwriting the existing object.", dwk_namespace);
    }

    // Add or update the object for the given namespace
    dwk_namespaceMap[dwk_namespace] = [DWKNamespaceObject dwk_namespaceObjectWithNamespace:dwk_namespace object:object];
}

- (void)dwk_removeJavascriptObject:(DWKNamespace)dwk_namespace {
    if (!dwk_namespaceMap[dwk_namespace]) {
        DWKLog(@"Warning: Namespace '%@' does not exist. Cannot remove.", dwk_namespace);
        return;
    }

    [dwk_namespaceMap removeObjectForKey:dwk_namespace];
}

- (BOOL)dwk_webView:(DWKWebView *)webView canHandleEvent:(DWKWebViewEvent *)eventName {
    DWKNamespaceObject *namespaceObject = dwk_namespaceMap[eventName.dwk_namespace];
    if (!namespaceObject) {
        DWKLog(@"Warning: Namespace '%@' does not exist.", eventName.dwk_namespace);
        return NO;
    }
    SEL dwk_selector = [namespaceObject dwk_selectorForMethod:eventName.dwk_method hasCompletion:eventName.dwk_callback != nil];
    if (!dwk_selector) {
        DWKLog(@"Warning: Method '%@' in namespace '%@' does not exist.", eventName.dwk_method, eventName.dwk_namespace);
        return NO;
    }
    return YES;
}

- (id)dwk_webView:(DWKWebView *)webView handleEvent:(DWKWebViewEvent *)eventName {
    DWKNamespaceObject *namespaceObject = dwk_namespaceMap[eventName.dwk_namespace];
    if (!namespaceObject) {
        DWKLog(@"Warning: Namespace '%@' does not exist.", eventName.dwk_namespace);
        return nil;
    }

    // Invoke the method with the provided arguments
    return [namespaceObject dwk_invokeWithSelector:eventName.dwk_method
                                          arguments:eventName.dwk_args
                                  completionHandler:eventName.dwk_callback];
}

@end

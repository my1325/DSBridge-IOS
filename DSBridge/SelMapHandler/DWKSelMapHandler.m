//
//  DWKSelMapHandler.m
//  dsbridge
//
//  Created by mayong on 2025/7/2.
//  Copyright © 2025 杜文. All rights reserved.
//

#import "DWKObjects.h"
#import "DWKSelMapHandler.h"
#import "DWKWebView.h"
#import "DWKUtil.h"

@interface DWKNamespaceSelMapObject : NSObject

@property (nonatomic, copy) NSString * dwk_namespace;

@property (nonatomic, strong) id dwk_object;

@property (nonatomic, copy) NSDictionary *dwk_originSelMap;

+ (instancetype)dwk_namespaceObjectWithNamespace:(NSString *)dwk_namespace
                                      withTarget: (id)dwk_target
                                      withSelMap: (NSDictionary *)dwk_selMap;

- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
               hasCompletion:(BOOL)dwk_hasCompletion;

- (id)dwk_invokeWithSelector:(NSString *)dwk_selectorName
                   arguments:(NSArray *)arguments
           completionHandler:(void (^)(id, BOOL))completionHandler;

@end

@implementation DWKNamespaceSelMapObject {
    NSMutableDictionary *dwk_selMap;
}

+ (instancetype)dwk_namespaceObjectWithNamespace:(NSString *)dwk_namespace
                                      withTarget:(id)dwk_target
                                      withSelMap:(NSDictionary *)dwk_selMap
{
    DWKNamespaceSelMapObject *dwk_namespaceObject = [[DWKNamespaceSelMapObject alloc] init];

    dwk_namespaceObject.dwk_namespace = dwk_namespace;
    dwk_namespaceObject.dwk_object = dwk_target;
    dwk_namespaceObject.dwk_originSelMap = dwk_selMap;
    [dwk_namespaceObject dwk_parseTarget];
    return dwk_namespaceObject;
}

- (void)dwk_parseTarget {
    dwk_selMap = [@{} mutableCopy];

    if (!_dwk_object) {
        DWKLog(@"Warning: Attempted to set a nil object for namespace '%@'.", self.dwk_namespace);
        return;
    }

    // Dynamically fetch methods from the object and store them in the map
    NSArray *dwk_targetMethodList = [_dwk_originSelMap allValues];
    if (!dwk_targetMethodList.count) {
        NSLog(@"Warning: No methods found in the origin selector map for namespace '%@'.", self.dwk_namespace);
        return;
    }
    
    NSSet *dwk_targetMethodSet = [NSSet setWithArray:dwk_targetMethodList];

    NSSet *dwk_methodSet = dwk_method_list_for_class([_dwk_object class]);
    
    for (NSString *dwk_key in _dwk_originSelMap) {
        NSString *dwk_methodName = [_dwk_originSelMap valueForKey:dwk_key];
        if (!dwk_methodName.length || ![dwk_methodSet containsObject:dwk_methodName]) {
            DWKLog(@"Warning: Method '%@' not found in the target object for namespace '%@'.", dwk_methodName, self.dwk_namespace);
            continue;
        }
        dwk_selMap[dwk_key] = [dwk_methodName copy];
    }
}

- (SEL)dwk_selectorForMethod:(NSString *)dwk_methodName
               hasCompletion:(BOOL)dwk_hasCompletion {
    if (!dwk_methodName.length || !self.dwk_object) {
        return nil;
    }
    
    NSString *dwk_keyName = [dwk_methodName copy];
    if (dwk_hasCompletion) {
        dwk_keyName = [dwk_keyName stringByAppendingString:@":"];
    }
    
    NSString *dwk_targetMethod = [dwk_selMap valueForKey:dwk_keyName];
    SEL dwk_resultSelector = NSSelectorFromString(dwk_targetMethod);
    if (!dwk_targetMethod.length || ![_dwk_object respondsToSelector:dwk_resultSelector]) {
        DWKLog(@"Warning: Method '%@' not found in the target object for namespace '%@'.", dwk_targetMethod, self.dwk_namespace);
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
    
    id args = arguments ?: @[];
    NSInteger dwk_colonCount = [NSStringFromSelector(dwk_selector) componentsSeparatedByString:@":"].count - 1;

    if (dwk_colonCount >= 2) {
        id dwk_callback = completionHandler ?: ^(id result, BOOL success) {
            // Default completion handler if none provided
            DWKLog(@"Default completion handler called with result: %@, success: %d", result, success);
        };
        
        dwk_invoke_method_with_callback(_dwk_object, dwk_selector, args, dwk_callback);
        return nil;
    }
    
    return dwk_invoke_method(_dwk_object, dwk_selector, arguments);
}

@end

@implementation DWKSelMapHandler {
    NSMutableDictionary *dwk_namespaceMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dwk_namespaceMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dwk_registerNamespace:(NSString *)dwk_namespace withTarget:(id)dwk_target withSelMap:(NSDictionary *)dwk_selMap {
    if (!dwk_target || !dwk_selMap.count) {
        DWKLog(@"Warning: Invalid parameters for registering namespace '%@'.", dwk_namespace);
        return;
    }
    
    DWKNamespaceSelMapObject *dwk_namespaceObject = [DWKNamespaceSelMapObject dwk_namespaceObjectWithNamespace:dwk_namespace
                                                                                                    withTarget:dwk_target
                                                                                                    withSelMap:dwk_selMap];
    
    if (!dwk_namespaceObject) {
        DWKLog(@"Warning: Failed to create namespace object for '%@'.", dwk_namespace);
        return;
    }
    
    if (dwk_namespaceMap[dwk_namespace]) {
        DWKLog(@"Warning: Namespace '%@' already registered, overwriting.", dwk_namespace);
    }
    
    dwk_namespaceMap[dwk_namespace] = dwk_namespaceObject;
}

- (void)dwk_removeTargetForNamespace:(NSString *)dwk_namespace {
    if (!dwk_namespaceMap[dwk_namespace]) {
        DWKLog(@"Warning: Namespace '%@' does not exist. Cannot remove.", dwk_namespace);
        return;
    }
    
    [dwk_namespaceMap removeObjectForKey:dwk_namespace];
}


- (BOOL)dwk_webView:(DWKWebView *)webView canHandleEvent:(DWKWebViewEvent *)eventName {
    DWKNamespaceSelMapObject *namespaceObject = dwk_namespaceMap[eventName.dwk_namespace];
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
    DWKNamespaceSelMapObject *namespaceObject = dwk_namespaceMap[eventName.dwk_namespace];
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


#import <objc/message.h>
#import "DWKObjects.h"
#import "DWKWebView.h"
//#import "InternalApis.h"
#import "DWKUtil.h"
#import "DWKWebView.h"

static NSString *const DWK_Event_Prefix = @"_dsbridge=";

@implementation DWKWebView{
    void (^ javascriptCloseWindowListener)(void);
    int callId;
    NSMutableDictionary *handerMap;
    NSMutableArray<DWKCallInfo *> *callInfoList;
    UInt64 lastCallTime;
    NSString *jsCache;
    bool isPending;
    bool isDebug;
}


- (instancetype)initWithFrame:(CGRect)frame
                configuration:(WKWebViewConfiguration *)configuration
{
    callId = 0;
    callInfoList = [@[] mutableCopy];
    handerMap = [@{} mutableCopy];
    lastCallTime = 0;
    jsCache = @"";
    isPending = false;
    isDebug = false;

    WKUserScript *script = [[WKUserScript alloc] initWithSource:@"window._dswk=true;"
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    self = [super initWithFrame:frame configuration:configuration];

    if (self) {
        super.UIDelegate = self;
    }

//    InternalApis *  interalApis= [[InternalApis alloc] init];
//    interalApis.webview=self;
//    [self addJavascriptObject:interalApis namespace:@"_dsb"];
    return self;
}

- (void)setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    self.dwk_uiDelegate = UIDelegate;
}

#pragma mark: - WKUIDelegate
#define DWK_UIDelegatePerformsSelector self.dwk_uiDelegate && [self.dwk_uiDelegate respondsToSelector:_cmd]
#define DWK_CanHandleEvent(dwk_event) [self.dwk_eventHandler dwk_webView:self canHandleEvent:dwk_event]


- (void)                          webView:(WKWebView *)webView
    runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
                              defaultText:(nullable NSString *)defaultText
                         initiatedByFrame:(WKFrameInfo *)frame
                        completionHandler:(void (^)(NSString *_Nullable result))completionHandler
{
    if ([prompt hasPrefix:DWK_Event_Prefix]) {
        NSString *dwk_originString = [prompt substringFromIndex:[DWK_Event_Prefix length]];
        NSString *dwk_result = nil;

        DWKWebViewEvent *dwk_event = DWK_Event_With_Origin(dwk_originString, defaultText);

        if (DWK_CanHandleEvent(dwk_event)) {
            dwk_result = [self.dwk_eventHandler dwk_webView:self handleEvent:dwk_event];
        } else {
            NSLog(@"Cannot handle event: %@", dwk_event);
            dwk_result = DWK_JSONString((@{ @"code": @-1, @"data": @"" }));
        }

        completionHandler(dwk_result);
    } else if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate              webView:webView
                   runJavaScriptTextInputPanelWithPrompt:prompt
                                             defaultText:defaultText
                                        initiatedByFrame:frame
                                       completionHandler:completionHandler];
    } else {
        completionHandler(nil);
    }
}

- (void)                           webView:(WKWebView *)webView
    requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
                          initiatedByFrame:(WKFrameInfo *)frame
                                      type:(WKMediaCaptureType)type
                           decisionHandler:(void (^)(WKPermissionDecision))decisionHandler  API_AVAILABLE(ios(15.0)) {
    if (DWK_UIDelegatePerformsSelector) {
        [self.dwk_uiDelegate               webView:webView
            requestMediaCapturePermissionForOrigin:origin
                                  initiatedByFrame:frame
                                              type:type
                                   decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKPermissionDecisionGrant);
    }
}

- (void)                       webView:(WKWebView *)webView
    runJavaScriptAlertPanelWithMessage:(NSString *)message
                      initiatedByFrame:(WKFrameInfo *)frame
                     completionHandler:(void (^)(void))completionHandler
{
    if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate           webView:webView
                   runJavaScriptAlertPanelWithMessage:message
                                     initiatedByFrame:frame
                                    completionHandler:completionHandler];
    } else {
        completionHandler();
    }
}

- (void)                         webView:(WKWebView *)webView
    runJavaScriptConfirmPanelWithMessage:(NSString *)message
                        initiatedByFrame:(WKFrameInfo *)frame
                       completionHandler:(void (^)(BOOL))completionHandler
{
    if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate             webView:webView
                   runJavaScriptConfirmPanelWithMessage:message
                                       initiatedByFrame:frame
                                      completionHandler:completionHandler];
    } else {
        completionHandler(YES);
    }
}

- (WKWebView *)            webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate       webView:webView
                   createWebViewWithConfiguration:configuration
                              forNavigationAction:navigationAction
                                   windowFeatures:windowFeatures];
    }

    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView {
    if (DWK_UIDelegatePerformsSelector) {
        [self.dwk_uiDelegate webViewDidClose:webView];
    }
}

- (BOOL)         webView:(WKWebView *)webView
    shouldPreviewElement:(WKPreviewElementInfo *)elementInfo
{
    if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate webView:webView shouldPreviewElement:elementInfo];
    }

    return NO;
}

- (UIViewController *)         webView:(WKWebView *)webView
    previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo
                        defaultActions:(NSArray<id<WKPreviewActionItem> > *)previewActions
{
    if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate           webView:webView
                   previewingViewControllerForElement:elementInfo
                                       defaultActions:previewActions];
    }

    return nil;
}

- (void)                   webView:(WKWebView *)webView
    commitPreviewingViewController:(UIViewController *)previewingViewController
{
    if (DWK_UIDelegatePerformsSelector) {
        return [self.dwk_uiDelegate webView:webView commitPreviewingViewController:previewingViewController];
    }
}

#undef DWK_UIDelegatePerformsSelector

#pragma mark: - Public Methods

- (void)evalJavascript:(int)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        @synchronized(self) {
            if ([jsCache length] != 0) {
                [self evaluateJavaScript:jsCache completionHandler:nil];
                isPending = false;
                jsCache = @"";
                lastCallTime = [[NSDate date] timeIntervalSince1970] * 1000;
            }
        }
    });
}

- (void)setDebugMode:(bool)debug {
    isDebug = debug;
}

- (void)loadUrl:(NSString *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    [self loadRequest:request];
}

- (void)callHandler:(NSString *)methodName
          arguments:(NSArray *)args
{
    [self     callHandler:methodName
                arguments:args
        completionHandler:nil];
}

- (void)  callHandler:(NSString *)methodName
    completionHandler:(void (^)(id _Nullable))completionHandler
{
    [self     callHandler:methodName
                arguments:nil
        completionHandler:completionHandler];
}

- (void)  callHandler:(NSString *)methodName
            arguments:(NSArray *)args
    completionHandler:(void (^)(id _Nullable value))completionHandler
{
    id dwk_callId = @(callId++);
    id dwk_args = args == nil ? @[] : args;
    DWKCallInfo *callInfo = DWK_CallInfo(methodName, dwk_callId, dwk_args);

    if (completionHandler) {
        [handerMap setObject:completionHandler forKey:callInfo.dwk_id];
    }

    if (callInfoList != nil) {
        [callInfoList addObject:callInfo];
    } else {
        [self dispatchJavascriptCall:callInfo];
    }
}

- (void)dispatchStartupQueue {
    if (callInfoList == nil) {
        return;
    }

    for (DWKCallInfo *dwk_callInfo in callInfoList) {
        [self dispatchJavascriptCall:dwk_callInfo];
    }

    callInfoList = nil;
}

//
- (void)dispatchJavascriptCall:(DWKCallInfo *)dwk_info {
    id dwk_infoObject = @{
        @"method": dwk_info.dwk_method,
        @"callbackId": dwk_info.dwk_id,
        @"data": DWK_JSONString(dwk_info.dwk_args)
    };
    [self evaluateJavaScript:[NSString stringWithFormat:@"window._handleMessageFromNative(%@)", DWK_JSONString(dwk_infoObject)]
           completionHandler:nil];
}

- (void)hasJavascriptMethod:(NSString *)handlerName
        methodExistCallback:(void (^)(bool exist))callback
{
    [self     callHandler:@"_hasJavascriptMethod"
                arguments:@[handlerName]
        completionHandler:^(NSNumber *_Nullable value) {
        callback([value boolValue]);
    }];
}

//- (NSString *)call:(NSString *)method:(NSString *)argStr
//{
//    NSArray *nameStr = [JSBUtil parseNamespace:[method stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
//
//    id JavascriptInterfaceObject = javaScriptNamespaceInterfaces[nameStr[0]];
//    NSString *error = [NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it", method];
//    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{ @"code": @-1, @"data": @"" }];
//
//    if (!JavascriptInterfaceObject) {
//        NSLog(@"Js bridge  called, but can't find a corresponded JavascriptObject , please check your code!");
//    } else {
//        method = nameStr[1];
//        NSString *methodOne = [JSBUtil methodByNameArg:1 selName:method class:[JavascriptInterfaceObject class]];
//        NSString *methodTwo = [JSBUtil methodByNameArg:2 selName:method class:[JavascriptInterfaceObject class]];
//        SEL sel = NSSelectorFromString(methodOne);
//        SEL selasyn = NSSelectorFromString(methodTwo);
//        NSDictionary *args = [JSBUtil jsonStringToObject:argStr];
//        id arg = args[@"data"];
//
//        if (arg == [NSNull null]) {
//            arg = nil;
//        }
//
//        NSString *cb;
//        do{
//            if (args && (cb = args[@"_dscbstub"])) {
//                if ([JavascriptInterfaceObject respondsToSelector:selasyn]) {
//                    __weak typeof(self) weakSelf = self;
//                    void (^ completionHandler)(id, BOOL) = ^(id value, BOOL complete) {
//                        NSString *del = @"";
//                        result[@"code"] = @0;
//
//                        if (value != nil) {
//                            result[@"data"] = value;
//                        }
//
//                        value = [JSBUtil objToJsonString:result];
//                        value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//                        if (complete) {
//                            del = [@"delete window." stringByAppendingString:cb];
//                        }
//
//                        NSString *js = [NSString stringWithFormat:@"try {%@(JSON.parse(decodeURIComponent(\"%@\")).data);%@; } catch(e){};", cb, (value == nil) ? @"" : value, del];
//                        __strong typeof(self) strongSelf = weakSelf;
//                        @synchronized(self)
//                        {
//                            UInt64 t = [[NSDate date] timeIntervalSince1970] * 1000;
//                            jsCache = [jsCache stringByAppendingString:js];
//
//                            if (t - lastCallTime < 50) {
//                                if (!isPending) {
//                                    [strongSelf evalJavascript:50];
//                                    isPending = true;
//                                }
//                            } else {
//                                [strongSelf evalJavascript:0];
//                            }
//                        }
//                    };
//
//                    void (*action)(id, SEL, id, id) = (void (*)(id, SEL, id, id))objc_msgSend;
//                    action(JavascriptInterfaceObject, selasyn, arg, completionHandler);
//                    break;
//                }
//            } else if ([JavascriptInterfaceObject respondsToSelector:sel]) {
//                id ret = [self run:JavascriptInterfaceObject sel:sel args:arg];
//                [result setValue:@0 forKey:@"code"];
//
//                if (ret != nil) {
//                    [result setValue:ret forKey:@"data"];
//                }
//
//                break;
//            }
//
//            NSString *js = [error stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//            if (isDebug) {
//                js = [NSString stringWithFormat:@"window.alert(decodeURIComponent(\"%@\"));", js];
//                [self evaluateJavaScript:js completionHandler:nil];
//            }
//
//            NSLog(@"%@", error);
//        }while (0);
//    }
//
//    return [JSBUtil objToJsonString:result];
//}
//
//- (id)run:(id)swiftObject
//      sel:(SEL)sel
//     args:(id)args
//{
//    if (![swiftObject respondsToSelector:sel]) {
//        return nil;
//    }
//
//    Method method1 = class_getInstanceMethod([swiftObject class], sel);
//    char retType[10];
//    method_getReturnType(method1, retType, 10);
//
//    if (strcmp("v", retType) == 0) {
//        void (*action)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
//        action(swiftObject, sel, args);
//        return nil;
//    } else {
//        id (*action)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
//        id ret = action(swiftObject, sel, args);
//        return ret;
//    }
//}
//
//- (void)setJavascriptCloseWindowListener:(void (^)(void))callback
//{
//    javascriptCloseWindowListener = callback;
//}
//

//

//
//- (void)addJavascriptObject:(id)object
//                  namespace:(NSString *)namespace
//{
//    if (namespace == nil) {
//        namespace = @"";
//    }
//
//    if (object != NULL) {
//        [javaScriptNamespaceInterfaces setObject:object forKey:namespace];
//    }
//}
//
//- (void)removeJavascriptObject:(NSString *)namespace {
//    if (namespace == nil) {
//        namespace = @"";
//    }
//
//    [javaScriptNamespaceInterfaces removeObjectForKey:namespace];
//}
//
//- (void)customJavascriptDialogLabelTitles:(NSDictionary *)dic {
//    if (dic) {
//        dialogTextDic = dic;
//    }
//}
//
//- (id)onMessage:(NSDictionary *)msg type:(int)type {
//    id ret = nil;
//
//    switch (type) {
//        case DSB_API_HASNATIVEMETHOD:
//            ret = [self hasNativeMethod:msg] ? @1 : @0;
//            break;
//
//        case DSB_API_CLOSEPAGE:
//            [self closePage:msg];
//            break;
//
//        case DSB_API_RETURNVALUE:
//            ret = [self returnValue:msg];
//            break;
//
//        case DSB_API_DSINIT:
//            ret = [self dsinit:msg];
//            break;
//
//        case DSB_API_DISABLESAFETYALERTBOX:
//            [self disableJavascriptDialogBlock:[msg[@"disable"] boolValue]];
//            break;
//
//        default:
//            break;
//    }
//    return ret;
//}
//
//- (bool)hasNativeMethod:(NSDictionary *)args
//{
//    NSArray *nameStr = [JSBUtil parseNamespace:[args[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
//    NSString *type = [args[@"type"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    id JavascriptInterfaceObject = [javaScriptNamespaceInterfaces objectForKey:nameStr[0]];
//
//    if (JavascriptInterfaceObject) {
//        bool syn = [JSBUtil methodByNameArg:1 selName:nameStr[1] class:[JavascriptInterfaceObject class]] != nil;
//        bool asyn = [JSBUtil methodByNameArg:2 selName:nameStr[1] class:[JavascriptInterfaceObject class]] != nil;
//
//        if (([@"all" isEqualToString:type] && (syn || asyn))
//            || ([@"asyn" isEqualToString:type] && asyn)
//            || ([@"syn" isEqualToString:type] && syn)
//            ) {
//            return true;
//        }
//    }
//
//    return false;
//}
//
//- (id)closePage:(NSDictionary *)args {
//    if (javascriptCloseWindowListener) {
//        javascriptCloseWindowListener();
//    }
//
//    return nil;
//}
//
//- (id)returnValue:(NSDictionary *)args {
//    void (^ completionHandler)(NSString *_Nullable) = handerMap[args[@"id"]];
//
//    if (completionHandler) {
//        if (isDebug) {
//            completionHandler(args[@"data"]);
//        } else {
//            @try {
//                completionHandler(args[@"data"]);
//            } @catch (NSException *e) {
//                NSLog(@"%@", e);
//            }
//        }
//
//        if ([args[@"complete"] boolValue]) {
//            [handerMap removeObjectForKey:args[@"id"]];
//        }
//    }
//
//    return nil;
//}
//
//- (id)dsinit:(NSDictionary *)args {
//    [self dispatchStartupQueue];
//    return nil;
//}
//
//- (void)hasJavascriptMethod:(NSString *)handlerName
//        methodExistCallback:(void (^)(bool exist))callback
//{
//    [self     callHandler:@"_hasJavascriptMethod"
//                arguments:@[handlerName]
//        completionHandler:^(NSNumber *_Nullable value) {
//        callback([value boolValue]);
//    }];
//}
//
@end

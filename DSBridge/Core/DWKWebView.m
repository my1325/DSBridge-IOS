#import "DWKObjects.h"
#import "DWKUtil.h"
#import "DWKWebView.h"
#import "DWKWebView.h"

static NSString *const DWK_Event_Prefix = @"_dsbridge=";

static NSString *const DWK_Event_Namespace_Internal = @"_dsb";

static NSString *const DWK_Event_Args_Callback = @"_dscbstub";

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
    if (![prompt hasPrefix:DWK_Event_Prefix]) {
        if (!DWK_UIDelegatePerformsSelector) {
            completionHandler(nil);
        }

        return [self.dwk_uiDelegate              webView:webView
                   runJavaScriptTextInputPanelWithPrompt:prompt
                                             defaultText:defaultText
                                        initiatedByFrame:frame
                                       completionHandler:completionHandler];
    }

    NSString *dwk_originString = [prompt substringFromIndex:[DWK_Event_Prefix length]];
    __block NSString *dwk_result = nil;

    id dwk_args = DWK_JSONObject(defaultText);
    id dwk_cb = [dwk_args valueForKey:DWK_Event_Args_Callback];
    DWKWebViewEvent *dwk_event;

    if (!dwk_cb) {
        dwk_event = DWK_Event_With_Origin(dwk_originString, [dwk_args valueForKey:@"data"]);
    } else {
        DWKEventCallback dwk_handler = [self dwk_eventCallbackWithId:dwk_cb
                                                    dwk_dataCallback:^(id data, BOOL complete) {
            NSMutableDictionary *dwk_cbResult = [@{} mutableCopy];
            [dwk_cbResult setValue:@0
                            forKey:@"code"];

            if (data != nil) {
                [dwk_cbResult setValue:data
                                forKey:@"data"];
            }

            dwk_result = DWK_JSONString(dwk_cbResult);
        }];

        dwk_event = DWK_Event_With_Handler(dwk_originString, [dwk_args valueForKey:@"data"], dwk_handler);
    }

    if ([dwk_event.dwk_namespace isEqualToString:DWK_Event_Namespace_Internal]) {
        dwk_result = [self dwk_dispatchInternalEvent:dwk_event];
        completionHandler(dwk_result);
        return;
    }

    if (DWK_CanHandleEvent(dwk_event)) {
        id dwk_data = [self.dwk_eventHandler dwk_webView:self handleEvent:dwk_event];
        NSMutableDictionary *dwk_cbResult = [@{ @"code": @0 } mutableCopy];
        if (dwk_data) {
            [dwk_cbResult setValue:dwk_data forKey:@"data"];
        }
        dwk_result = DWK_JSONString(dwk_cbResult);
    } else {
        DWKLog(@"Cannot handle event: %@", dwk_event);
        dwk_result = DWK_JSONString((@{ @"code": @-1, @"data": @"" }));
    }

    completionHandler(dwk_result);
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

#undef DWK_UIDelegatePerformsSelector

#pragma mark: - Public Methods

- (void)evalJavascript:(int)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        @synchronized(self) {
            if ([self->jsCache length] != 0) {
                DWKLog(@"Eval Javascript: %@", self->jsCache);
                [self evaluateJavaScript:self->jsCache completionHandler:nil];
                self->isPending = false;
                self->jsCache = @"";
                self->lastCallTime = [[NSDate date] timeIntervalSince1970] * 1000;
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

#pragma mark: - callback
- (DWKEventCallback)dwk_eventCallbackWithId:(id)dwk_cb
                           dwk_dataCallback:(void (^)(id data, BOOL complete))dwk_dataCallback
{
    __weak typeof(self) weakSelf = self;
    return ^(id dwk_value, BOOL dwk_complete) {
               if (!dwk_dataCallback) {
                   dwk_dataCallback(dwk_value, dwk_complete);
               }

               NSString *dwk_del = @"";
               NSDictionary *dwk_data = @{
                       @"code": @0,
                       @"data": dwk_value ? : @""
               };

               NSString *dwk_retValue = DWK_JSONString(dwk_data);

               if (dwk_complete) {
                   dwk_del = [@"delete window." stringByAppendingString:dwk_cb];
               }

               NSString *js = [NSString stringWithFormat:@"try {%@(JSON.parse(decodeURIComponent('%@')).data);%@; } catch(e){};", dwk_cb, (dwk_retValue == nil) ? @"" : dwk_retValue, dwk_del];
               __strong typeof(self) strongSelf = weakSelf;
               @synchronized(self)
               {
                   UInt64 t = [[NSDate date] timeIntervalSince1970] * 1000;
                   self->jsCache = [self->jsCache stringByAppendingString:js];

                   if (t - self->lastCallTime < 50) {
                       if (!self->isPending) {
                           [strongSelf evalJavascript:50];
                           self->isPending = true;
                       }
                   } else {
                       [strongSelf evalJavascript:0];
                   }
               }
    };
}

#pragma mark: - Internal Event Handling
/// 内部事件处理
- (NSString *)dwk_dispatchInternalEvent:(DWKWebViewEvent *)dwk_event {
    if (!dwk_event) {
        return DWK_JSONString((@{ @"code": @-1, @"data": @"" }));
    }

    if (![dwk_event.dwk_namespace isEqualToString:DWK_Event_Namespace_Internal]) {
        return DWK_JSONString((@{ @"code": @-1, @"data": @"" }));
    }

    id dwk_data = nil;

    if ([dwk_event.dwk_method isEqualToString:@"closePage"]) {
        dwk_data = [self closePage:dwk_event.dwk_args];
    } else if ([dwk_event.dwk_method isEqualToString:@"returnValue"]) {
        dwk_data = [self returnValue:dwk_event.dwk_args];
    } else if ([dwk_event.dwk_method isEqualToString:@"hasNativeMethod"]) {
        dwk_data = [self hasNativeMethod:dwk_event.dwk_args];
    } else if ([dwk_event.dwk_method isEqualToString:@"dsinit"]) {
        dwk_data = [self dsinit:dwk_event.dwk_args];
    }

    return DWK_JSONString((@{ @"code": @0, @"data": dwk_data ? : @"" }));
}

- (id)hasNativeMethod:(id)args {
    NSString *dwk_name = [args valueForKey:@"name"];

    if (!dwk_name.length) {
        return @(NO);
    }

    dwk_name = [dwk_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    DWKWebViewEvent *dwk_webEvent = DWK_Event_With_Origin(dwk_name, @{});
    DWKWebViewEvent *dwk_webEventWithHandler = DWK_Event_With_Handler(dwk_name, @{}, ^(id dwk_data, BOOL dwk_complete) {});

    NSString *type = [[args valueForKey:@"type"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    BOOL dwk_retValue = NO;

    if ([type isEqualToString:@"all"]) {
        dwk_retValue =  DWK_CanHandleEvent(dwk_webEvent) || DWK_CanHandleEvent(dwk_webEventWithHandler);
    } else if ([type isEqualToString:@"asyn"]) {
        dwk_retValue =  DWK_CanHandleEvent(dwk_webEventWithHandler);
    } else if ([type isEqualToString:@"syn"]) {
        dwk_retValue = DWK_CanHandleEvent(dwk_webEvent);
    } else {
        dwk_retValue = NO;
    }

    return @(dwk_retValue);
}

- (id)closePage:(id)args {
    if (javascriptCloseWindowListener) {
        javascriptCloseWindowListener();
    }

    return nil;
}

- (id)returnValue:(id)args {
    void (^ completionHandler)(NSString *_Nullable) = handerMap[args[@"id"]];

    if (completionHandler) {
        if (isDebug) {
            completionHandler(args[@"data"]);
        } else {
            @try {
                completionHandler(args[@"data"]);
            } @catch (NSException *e) {
                NSLog(@"%@", e);
            }
        }

        if ([args[@"complete"] boolValue]) {
            [handerMap removeObjectForKey:args[@"id"]];
        }
    }

    return nil;
}

- (id)dsinit:(id)args {
    [self dispatchStartupQueue];
    return nil;
}

@end

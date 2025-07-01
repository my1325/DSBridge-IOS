//
//  DSWKwebview.h
//  dspider
//
//  Created by 杜文 on 16/12/28.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <WebKit/WebKit.h>

@class DWKWebView, DWKWebViewEvent;

@protocol DWKWebViewHandler <NSObject>
- (BOOL)dwk_webView:(DWKWebView *_Nonnull)webView
     canHandleEvent:(DWKWebViewEvent *_Nonnull)eventName;

- (id _Nullable)dwk_webView:(DWKWebView *_Nonnull)webView
                handleEvent:(DWKWebViewEvent *_Nonnull)eventName;
@end

typedef void (^JSCallback)(NSString *_Nullable result, BOOL complete);

@interface DWKWebView : WKWebView <WKUIDelegate>

@property (nullable, nonatomic, weak) id <WKUIDelegate> dwk_uiDelegate;

@property (nonnull, nonatomic, strong) id<DWKWebViewHandler> dwk_eventHandler;

- (void)loadUrl:(NSString *_Nonnull)url;

// Call javascript handler
- (void)callHandler:(NSString *_Nonnull)methodName
          arguments:(NSArray *_Nullable)args;

- (void)  callHandler:(NSString *_Nonnull)methodName
    completionHandler:(void (^_Nullable)(id _Nullable value))completionHandler;

- (void)  callHandler:(NSString *_Nonnull)methodName
            arguments:(NSArray *_Nullable)args
    completionHandler:(void (^_Nullable)(id _Nullable value))completionHandler;

- (void)hasJavascriptMethod:(NSString *_Nonnull)handlerName
        methodExistCallback:(void (^_Nullable)(bool exist))callback;

- (void)setDebugMode:(bool)debug;

#pragma mark: - web的系统事件
- (id _Nullable)hasNativeMethod:(NSDictionary *_Nullable)args;

- (id _Nullable)closePage:(NSDictionary *_Nullable)args;

- (id _Nullable)returnValue:(NSDictionary *_Nullable)args;

- (id _Nullable)dsinit:(NSDictionary *_Nullable)args;
@end

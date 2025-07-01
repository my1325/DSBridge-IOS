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


// Test whether the handler exist in javascript
- (void)hasJavascriptMethod:(NSString *_Nonnull)handlerName
        methodExistCallback:(void (^_Nullable)(bool exist))callback;

// Set debug mode. if in debug mode, some errors will be prompted by a dialog
// and the exception caused by the native handlers will not be captured.
- (void)setDebugMode:(bool)debug;

// private method, the developer shoudn't call this method
//- (id _Nullable)onMessage:(NSDictionary *_Nonnull)msg type:(int)type;

@end

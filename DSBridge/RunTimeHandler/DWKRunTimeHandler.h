//
//  DWKRunTimeHandler.h
//  dsbridge
//
//  Created by mayong on 2025/7/1.
//  Copyright © 2025 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DWKWebViewHandler;
@class DWKWebView, DWKWebViewEvent;

NS_ASSUME_NONNULL_BEGIN

typedef NSString * _Nonnull DWKNamespace;
@interface DWKRunTimeHandler : NSObject<DWKWebViewHandler>

@property (nonatomic, strong, readonly) NSDictionary *dwk_javascriptObjects;

- (void)dwk_addJavascriptObject:(id _Nonnull)object forNamespace:(DWKNamespace)dwk_namespace;
               
- (void)dwk_removeJavascriptObject:(DWKNamespace) dwk_namespace;

- (id)dwk_webView:(DWKWebView *)webView handleEvent:(DWKWebViewEvent *)event;

- (BOOL)dwk_webView:(DWKWebView *)webView canHandleEvent:(DWKWebViewEvent *)event;
@end

NS_ASSUME_NONNULL_END

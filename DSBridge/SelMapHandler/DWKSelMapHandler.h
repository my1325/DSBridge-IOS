//
//  DWKSelMapHandler.h
//  dsbridge
//
//  Created by mayong on 2025/7/2.
//  Copyright © 2025 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DWKWebViewHandler;

@class DWKWebView, DWKWebViewEvent;

NS_ASSUME_NONNULL_BEGIN

@interface DWKSelMapHandler : NSObject<DWKWebViewHandler>

@property (nonatomic, strong, readonly) NSDictionary *dwk_selMap;

@property (nonatomic, strong, readonly) id dwk_target;

+ (instancetype)dwk_handlerWithTarget:(id)dwk_target selMap:(NSDictionary *)dwk_selMap;

- (id)dwk_webView:(DWKWebView *)webView handleEvent:(DWKWebViewEvent *)event;

- (BOOL)dwk_webView:(DWKWebView *)webView canHandleEvent:(DWKWebViewEvent *)event;
@end

NS_ASSUME_NONNULL_END

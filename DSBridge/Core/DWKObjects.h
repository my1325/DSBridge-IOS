//
//  DWKWebViewEvent.h
//  dsbridge
//
//  Created by mayong on 2025/7/1.
//  Copyright © 2025 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DWKEventCallback)(id _Nullable result, BOOL complete);

@interface DWKWebViewEvent : NSObject

@property (nonatomic, copy) NSString *dwk_namespace;

@property (nonatomic, copy) NSString *dwk_method;

@property (nonatomic, copy) DWKEventCallback dwk_callback;

@property (nonatomic, copy) id dwk_args;

+ (instancetype)dwk_eventWithNamespace:(NSString *)dwk_namespace
                                 method:(NSString *)dwk_method
                                    args:(id)dwk_args;

+ (instancetype)dwk_eventWithNamespace:(NSString *)dwk_namespace
                                 method:(NSString *)dwk_method
                                    args:(id)dwk_args
                         callback:(DWKEventCallback _Nullable)dwk_callback;
@end


@interface DWKCallInfo : NSObject
@property (nullable, nonatomic, copy) NSString* dwk_method;

@property (nullable, nonatomic, copy) NSNumber* dwk_id;

@property (nullable,nonatomic, copy) NSArray * dwk_args;

+ (instancetype)dwk_callInfoWithMethod:(NSString *)dwk_method
                                dwk_id:(NSNumber *)dwk_id
                              dwk_args:(NSArray *)dwk_args;
@end

NS_ASSUME_NONNULL_END

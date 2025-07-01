#import <Foundation/Foundation.h>

//enum {
//    DSB_API_HASNATIVEMETHOD,
//    DSB_API_CLOSEPAGE,
//    DSB_API_RETURNVALUE,
//    DSB_API_DSINIT,
//    DSB_API_DISABLESAFETYALERTBOX
//};

//@interface JSBUtil : NSObject
//
//+ (NSString * _Nullable)objToJsonString:(id  _Nonnull)dict;
//
//+ (id  _Nullable)jsonStringToObject:(NSString * _Nonnull)jsonString;
//
//+(NSString *_Nullable)methodByNameArg:(NSInteger)argNum
//                              selName:( NSString * _Nullable)selName
//class:(Class _Nonnull )class;
//
//+ (NSArray *_Nonnull)parseNamespace: (NSString *_Nonnull) method;
//@end

@class DWKWebViewEvent, DWKCallInfo;
#ifndef DWK_Event
#define DWK_Event_With_Origin(dwk_originString, dwk_argsString) \
    dwk_event_with_origin(dwk_originString, dwk_argsString)
#endif

#ifndef DWK_CallInfo
#define DWK_CallInfo(dwk_method, dwk_ID, dwk_args) \
    [DWKCallInfo dwk_callInfoWithMethod:dwk_method dwk_id:dwk_ID dwk_args:dwk_args]
#endif

#ifndef DWK_JSONString
#define DWK_JSONString(dwk_obj) \
    dwk_to_json_string(dwk_obj)
#endif

#ifndef DWK_JSONObject
#define DWK_JSONObject(dwk_json_string) \
    dwk_to_json_object(dwk_json_string)
#endif

extern inline DWKWebViewEvent * _Nonnull dwk_event_with_origin(NSString *_Nonnull dwk_originString, NSString *_Nonnull dwk_argsString);

extern inline NSString * _Nonnull dwk_to_json_string(id _Nonnull dict);

extern inline NSDictionary * _Nonnull dwk_to_json_object(NSString *_Nonnull dwk_json_string);

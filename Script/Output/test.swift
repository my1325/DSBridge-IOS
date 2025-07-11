import AVFoundation
import OneSignalFramework

import AdSupport
import Alamofire
import AppsFlyerLib
import AppTrackingTransparency
import AuthenticationServices
import Combine
import DSBridge
import Foundation
import GeTools
import SafariServices
import SnapKit
import StoreKit
import TDMobRisk

// import Telegraph
import WebKit

struct FinoBoxerModel_Receipt: Codable {
    let finoBoxer_userId: String
    let finoBoxer_productId: String
    let finoBoxer_receiptString: String
}

@propertyWrapper
struct FinoBoxerDefaultPlistWrapper<V> {
    let finoBoxer_key: String
    let finoBoxer_default: V?
    init(_ finoBoxer_key: String, finoBoxer_default: V? = nil) {
        self.finoBoxer_key = finoBoxer_key
        self.finoBoxer_default = finoBoxer_default
    }
    
    var wrappedValue: V? {
        get { (UserDefaults.standard.value(forKey: finoBoxer_key) as? V) ?? finoBoxer_default }
        set { UserDefaults.standard.setValue(newValue, forKey: finoBoxer_key) }
    }
}

final class FinoBoxerDispatcherLogin: NSObject {
    init(finoBoxer_loginSuccessAction: @escaping FinoBoxerLoginSuccessAction) {
        self.finoBoxer_loginSuccessAction = finoBoxer_loginSuccessAction
    }
    
    let finoBoxer_loginSuccessAction: FinoBoxerLoginSuccessAction
    
    typealias FinoBoxerLoginSuccessAction = (String, Int, String) -> Void
    private var finoBoxer_sinkCollection: Set<AnyCancellable> = []
    
    @objc func build_wisdom_zenith(_ arg: Any?, observe_session: (Any?) -> Void) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_session: String = finoBoxer_info["session"] as? String,
              let finoBoxer_accountId: Int = finoBoxer_info["accountId"] as? Int,
              let finoBoxer_displayAccountId: String = finoBoxer_info["displayAccountId"] as? String
        else {
            return
        }
        
        let finoBoxer_isNewUser = finoBoxer_info["isNewUser"] as? Bool
        if finoBoxer_isNewUser == true {
            AppsFlyerLib.shared().logEvent(AFEventCompleteRegistration, withValues: [:])
        }
        
        finoBoxer_loginSuccessAction(
            finoBoxer_session,
            finoBoxer_accountId,
            finoBoxer_displayAccountId
        )
    }

    @objc func evaluate_victory(_ arg: Any?, universe: @escaping (Any?) -> Void) {
//        handler(["nickName":nick,"email":email,"key":key])
        ASAuthorizationAppleIDProvider().requestPublisher(fino_appWindow!)
            .sink {
                switch $0 {
                case .failure:
                    universe([:])
                default: break
                }
            } receiveValue: { finoBoxer_response in
                universe([
                    "nickName": finoBoxer_response.nickName,
                    "email": finoBoxer_response.email,
                    "key": finoBoxer_response.openId
                ])
            }
            .store(in: &finoBoxer_sinkCollection)
    }
}

final class FinoBoxerDispatcherPage: NSObject {
    init(finoBoxer_pageGetter: @escaping FinoBoxerDispatcherPageGetter, finoBoxer_navigationbarEnable: @escaping FinoBoxerNavigationBarEnableAction) {
        self.finoBoxer_pageGetter = finoBoxer_pageGetter
        self.finoBoxer_navigationbarEnable = finoBoxer_navigationbarEnable
    }

    let finoBoxer_navigationbarEnable: FinoBoxerNavigationBarEnableAction
    let finoBoxer_pageGetter: FinoBoxerDispatcherPageGetter
    typealias FinoBoxerNavigationBarEnableAction = (Bool) -> Void
    typealias FinoBoxerDispatcherPageGetter = () -> DWKWebView
    
    @objc func island_dispatch_message_submit_register(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_enable = finoBoxer_info["enable"] as? Int
        else {
            return
        }
        finoBoxer_pageGetter().allowsBackForwardNavigationGestures = (finoBoxer_enable == 1)
    }

    @objc func elephant_provider_submit(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_enable = finoBoxer_info["enable"] as? Int
        else {
            return
        }
        finoBoxer_navigationbarEnable(finoBoxer_enable == 1)
    }
    
    @objc func refresh_result(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_enable = finoBoxer_info["enable"] as? Int
        else {
            return
        }
        finoBoxer_pageGetter().scrollView.contentInsetAdjustmentBehavior = (finoBoxer_enable == 1) ? .never : .automatic
    }
}

final class FinoBoxerDispatcherPay: NSObject {
    init(
        finoBoxer_receiptGetter: @escaping FinoBoxerReceiptGetter,
        finoBoxer_receiptSetter: @escaping FinoBoxerReceiptSetter
    ) {
        self.finoBoxer_receiptGetter = finoBoxer_receiptGetter
        self.finoBoxer_receiptSetter = finoBoxer_receiptSetter
    }

    let finoBoxer_receiptGetter: FinoBoxerReceiptGetter
    let finoBoxer_receiptSetter: FinoBoxerReceiptSetter
    
    private var finoBoxer_sinkCollection: Set<AnyCancellable> = []
    typealias FinoBoxerReceiptSetter = ([String]) -> Void
    typealias FinoBoxerReceiptGetter = () -> [String]
    
    var finoboxer_transations: [SKPaymentTransaction] = []

    func finoBoxer_recharge(
        _ finoBoxer_productId: String,
        finoBoxer_callback: @escaping (Result<String, Fino_ViewError>
        ) -> Void
    ) {
        Fino_RechargeManager.fino_shared.fino_addPayment(
            finoBoxer_productId, fino_completion: {
                switch $0 {
                case let .success(finoboxer_transations):
                    self.finoboxer_transations = finoboxer_transations
                    if let finoBoxer_receiptURL = Bundle.main.appStoreReceiptURL,
                       let finoBoxer_receiptData = try? Data(contentsOf: finoBoxer_receiptURL)
                    {
                        let finoBoxer_receiptString = finoBoxer_receiptData.base64EncodedString()
                        finoBoxer_callback(.success(finoBoxer_receiptString))
                    } else {
                        finoBoxer_callback(.failure(.fino_rechargeFailed))
                    }
                case .failure:
                    finoBoxer_callback(.failure(.fino_rechargeFailed))
                }
            }
        )
    }
    
    @objc func action(_ arg: Any?, encode_data: @escaping (Any?) -> Void) {
        Fino_RechargeManager.fino_shared.fino_restoreCompletedTransactions {
            switch $0 {
            case let .success(finoboxer_transations) where !finoboxer_transations.isEmpty:
                self.finoboxer_transations = finoboxer_transations
                if let finoBoxer_receiptURL = Bundle.main.appStoreReceiptURL,
                   let finoBoxer_receiptData = try? Data(contentsOf: finoBoxer_receiptURL)
                {
                    let finoBoxer_receiptString = finoBoxer_receiptData.base64EncodedString()
                    encode_data(["codes": [finoBoxer_receiptString]])
                } else {
                    encode_data(["codes": []])
                }
            default:
                encode_data(["codes": []])
            }
        }
    }
    
    // 该凭证已核销，删除本地凭证
    @objc func filter(_ arg: Any?, sunset_provider_load: (Any?) -> Void) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_code = finoBoxer_info["code"] as? String
        else {
            sunset_provider_load(nil)
            return
        }
        for finoboxer_transation in finoboxer_transations {
            Fino_RechargeManager.fino_shared.fino_finishTransaction(finoboxer_transation)
        }
    }
    
    // 核销成功，删除本地凭证，AF上报
    @objc func action(_ arg: Any?, data_observe: (Any?) -> Void) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_code = finoBoxer_info["code"] as? String,
              let finoBoxer_productId = finoBoxer_info["productId"] as? String,
              let finoBoxer_priceUSD = finoBoxer_info["priceUSD"] as? Double,
              let finoBoxer_coefficient = finoBoxer_info["coefficient"] as? Double
        else {
            data_observe(nil)
            return
        }
        
        for finoboxer_transation in finoboxer_transations {
            Fino_RechargeManager.fino_shared.fino_finishTransaction(finoboxer_transation)
        }
        
        var finoBoxer_receipts = finoBoxer_receiptGetter()
        finoBoxer_receipts.removeAll(where: { $0 == finoBoxer_code })
        finoBoxer_receiptSetter(finoBoxer_receipts)

        AppsFlyerLib.shared().logEvent(
            name: AFEventPurchase,
            values: [
                AFEventParamContentId: finoBoxer_productId,
                AFEventParamContentType: "category_a",
                AFEventParamRevenue: String(finoBoxer_priceUSD * finoBoxer_coefficient / 10000),
                AFEventParamCurrency: "USD"
            ],
            completionHandler: { _, _ in
            }
        )
    }

    @objc func process(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_productId = finoBoxer_info["productId"] as? String,
              let finoBoxer_priceUSD = finoBoxer_info["priceUSD"] as? Double,
              let finoBoxer_coefficient = finoBoxer_info["coefficient"] as? Double
        else {
            return
        }
        
        AppsFlyerLib.shared().logEvent(
            name: AFEventPurchase,
            values: [
                AFEventParamContentId: finoBoxer_productId,
                AFEventParamContentType: "category_a",
                AFEventParamRevenue: String(finoBoxer_priceUSD * finoBoxer_coefficient / 10000),
                AFEventParamCurrency: "USD"
            ],
            completionHandler: { _, _ in
            }
        )
    }
}

final class FinoBoxerDispatcherSystem: NSObject {
    init(
        finoBoxer_appConfig: FinoBoxerConfig,
        finoBoxer_rechargeSuccess: @escaping FinoBoxerSysmteObjectRechargeSuccess,
        finoBoxer_showRechargeAlert: @escaping FinoBoxerShowRechargeAlerAction,
        finoBoxer_appleBannerEnable: @escaping FinoBoxerAppleBannerEnable,
        finoBoxer_recorderCheckerEnable: @escaping FinoBoxerRecordChekerEanble,
        finoBoxer_logoutAction: @escaping FinoBoxerLogoutAction,
        finoBoxer_callJS: @escaping FinoBoxerCallJavascript,
        finoBoxer_callhandler: @escaping (String, Any) -> Void,
        finoBoxer_recharegeAction: @escaping FinoBoxerRechargeAction
    ) {
        self.finoBoxer_appConfig = finoBoxer_appConfig
        self.finoBoxer_rechargeSuccess = finoBoxer_rechargeSuccess
        self.finoBoxer_recorderCheckerEnable = finoBoxer_recorderCheckerEnable
        self.finoBoxer_appleBannerEnable = finoBoxer_appleBannerEnable
        self.finoBoxer_showRechargeAlert = finoBoxer_showRechargeAlert
        self.finoBoxer_logoutAction = finoBoxer_logoutAction
        self.finoBoxer_callJS = finoBoxer_callJS
        self.finoBoxer_callhandler = finoBoxer_callhandler
        self.finoBoxer_recharegeAction = finoBoxer_recharegeAction
    }

    typealias FinoBoxerLogoutAction = () -> Void
    let finoBoxer_appleBannerEnable: FinoBoxerAppleBannerEnable
    
    var finoBoxer_accountId: String = ""
    let finoBoxer_callhandler: (String, Any) -> Void
    let finoBoxer_rechargeSuccess: FinoBoxerSysmteObjectRechargeSuccess
    let finoBoxer_recharegeAction: FinoBoxerRechargeAction
    var finoBoxer_returnedIDFA: Bool = false
    typealias FinoBoxerSysmteObjectRechargeSuccess = (String, String) -> Void
    typealias FinoBoxerShowRechargeAlerAction = (String, @escaping (Int) -> Void) -> Void
    typealias FinoBoxerRechargeAction = (String, @escaping (String, Bool) -> Void) -> Void
    typealias FinoBoxerRecordChekerEanble = (Bool) -> Void
    typealias FinoBoxerAppleBannerEnable = (Bool) -> Void
    let finoBoxer_callJS: FinoBoxerCallJavascript
    
    @FinoBoxerDefaultPlistWrapper("finoboxer_langCode")
    private var finoBoxer_langCode: String?
    typealias FinoBoxerCallJavascript = (String) -> Void
    
    var finoBoxer_returnedTd: Bool = false
    private var finoBoxer_sinkCollection: Set<AnyCancellable> = []
    let finoBoxer_logoutAction: FinoBoxerLogoutAction
    let finoBoxer_recorderCheckerEnable: FinoBoxerRecordChekerEanble
    let finoBoxer_appConfig: FinoBoxerConfig
    let finoBoxer_showRechargeAlert: FinoBoxerShowRechargeAlerAction
    
    @objc func report_operation_export_chain_xylophone_cache_confirm(_ arg: Any?, garden: @escaping (Any?) -> Void) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_url = finoBoxer_info["url"] as? String,
              let finoBoxer_openURL = URL(string: finoBoxer_url)
        else {
            garden(["success": 2])
            return
        }
        
        let finoBoxer_isBrower = finoBoxer_info["isbrower"] as? Bool
        if finoBoxer_isBrower == true,
           UIApplication.shared.canOpenURL(finoBoxer_openURL)
        {
            UIApplication.shared.open(finoBoxer_openURL)
            garden(["success": 1])
            return
        }
        
        let finoBoxer_webView = SFSafariViewController(url: finoBoxer_openURL)
        fino_appWindow?.rootViewController?
            .present(
                finoBoxer_webView,
                animated: true
            )
        garden(["success": 1])
    }
    
    @objc func notification_elephant_refresh(_ arg: Any?, state: @escaping (Any?) -> Void) {
        guard let finoBoxer_productConfig = arg as? [String: Any],
              let finoBoxer_productId = finoBoxer_productConfig["productId"] as? String
        else {
            state(["code": "", "success": 0])
            return
        }
        finoBoxer_recharegeAction(
            finoBoxer_productId,
            { finoBoxer_receiptString, success in
                if success {
                    state(["code": finoBoxer_receiptString, "success": 1])
                } else {
                    state(["code": "", "success": 0])
                }
            }
        )
    }
    
    func finoBoxer_retrunIdFA() {
        guard !finoBoxer_returnedIDFA else {
            return
        }
        finoBoxer_returnedIDFA = true
        let finoBoxer_idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        finoBoxer_callhandler("idfa", ["code": finoBoxer_idfa])
    }
    
    @objc func load_flow_execute(_ arg: Any?) {
        finoBoxer_logoutAction()
    }
    
    @objc func dragon(_ arg: Any?) {
//        finoboxer_returnTDIfNeeded()
//        finoboxer_retrunIdFA()
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_key = finoBoxer_info["key"] as? String,
              let finoBoxer_user = finoBoxer_info["user"] as? [String: Any],
              let userId = finoBoxer_user["account_id"] as? Int
        else {
            return
        }
        let finoBoxer_params: [String: Any]? = finoBoxer_info["params"] as? [String: Any]
//        NSInteger zone = NSTimeZone.localTimeZone.secondsFromGMT / 3600;
//        [properties setValue:@(zone) forKey:@"#zone_offset"];
        var finoBoxer_properties: [String: Any] = [
            "app_name": Fino_ViewConfig.fino_appName,
            "app_channel": Fino_ViewConfig.fino_appChannel,
            "#zone_offset": Int(TimeZone.current.secondsFromGMT() / 3600)
//            "#type": "user_set",
//            "#account_id": userId,
        ]
        
        var finoBoxer_type = "user_set"
        if finoBoxer_key != "login" {
            finoBoxer_type = "track"
//            finoboxer_properties["#type"] = "track"
//            finoboxer_properties["#event_name"] = finoboxer_key
        }
        
        finoBoxer_properties.merge(finoBoxer_user, uniquingKeysWith: { $1 })
        if let finoBoxer_params {
            finoBoxer_properties.merge(finoBoxer_params, uniquingKeysWith: { $1 })
        }
        
        #if DEBUG
        let finoBoxer_isDebug = 1
        #else
        let finoBoxer_isDebug = 0
        #endif
        
        let finoBoxer_body: [String: Any] = [
            "debug": finoBoxer_isDebug,
            "appid": finoBoxer_appConfig.finoBoxer_thinkingAppId,
            "data": [
                "#time": Date().serializeToString("yyyy-MM-dd HH:mm:ss"),
                "#type": finoBoxer_type,
                "#event_name": finoBoxer_key,
                "#account_id": String(userId),
                "properties": finoBoxer_properties,
                "#distinct_id": FinoBoxerData.finoBoxer_shared.finoBoxer_uuidString
            ]
        ]
        // 请求
        let url = finoBoxer_appConfig.finoBoxer_thinkingUrl + "/sync_json"
        let finoBoxer_requestHeader = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "client": "1"
        ]
        
        Session.default.request(
            url,
            method: .post,
            parameters: finoBoxer_body,
            encoding: JSONEncoding.default,
            headers: HTTPHeaders(finoBoxer_requestHeader.map { .init(name: $0.key, value: $0.value) })
        )
        .responseDecodable { (_: AFDataResponse<FinoBoxerEmptyObject>) in
        }
        .resume()
    }
    
    @objc func adapt(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_enable = finoBoxer_info["enable"] as? Int
        else {
            return
        }
        finoBoxer_appleBannerEnable(finoBoxer_enable == 1)
    }

    @objc func transform_alert_state(_ arg: Any?, data: @escaping (Any?) -> Void) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_url = finoBoxer_info["url"] as? String
        else {
            data(["success": 0])
            return
        }
        finoBoxer_showRechargeAlert(finoBoxer_url) {
            data(["success": $0])
        }
    }
    
    @objc func retry_output_session_factory(_ arg: Any?) -> String {
        finoBoxer_langCode ?? "auto"
    }
    
    func finoBoxer_returnTDIfNeeded() {
        guard !finoBoxer_returnedTd else {
            return
        }
        defer { finoBoxer_returnedTd = true }
//
        finoBoxer_callhandler(
            "blackboxCode",
            ["code": TDMobRiskManager.sharedManager().pointee.getBlackBox().orEmpty]
        )
    }
    
    @objc func message_task_profile_retry_value(_ arg: Any?, observe: @escaping (Any?) -> Void) {
        let finoBoxer_info: [String: Any] = [
            "deviceModel": Fino_ViewConfig.fino_deviceName,
            "systemType": 1,
            "systemVersion": UIDevice.current.systemVersion,
            "phoneNumber": "",
            "carrier": FinoBoxerData.finoBoxer_shared.finoBoxer_carrier,
            "countryCode": (UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String)?.components(separatedBy: "-").last ?? "en_US",
            "languageCode": (UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String)?.components(separatedBy: "-").first ?? "en"
        ]
        observe(finoBoxer_info)
    }
    
    @objc func wisdom_evaluate_wisdom_factory_action_data(_ arg: Any?) -> String {
//        String(863)
        FinoBoxerViewData.finoBoxer_config!.finoBoxer_channelId!
    }
    
    @objc func encode_cherry_jungle(_ arg: Any?) {
        finoBoxer_callJS("var video = document.getElementById('vap_video'); video.muted = false;")
    }
    
    @objc func message_task_sunset_event(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_lang = finoBoxer_info["lang"] as? String
        else {
            return
        }
        finoBoxer_langCode = finoBoxer_lang
    }

    @objc func evaluate_island_process(_ arg: Any?) {
        SKStoreReviewController.requestReview()
    }
    
    @objc func service_observe_factory_profile_condition_encode_analytics(_ arg: Any?) {
        if let finoBoxer_settingURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(finoBoxer_settingURL)
        {
            UIApplication.shared.open(finoBoxer_settingURL)
        }
    }
    
    // MARK: - - private
    
    @objc func build_service_request_backup_service(_ arg: Any?) -> String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    @objc func data_forest_format_alert_balance(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_enable = finoBoxer_info["enable"] as? Int
        else {
            return
        }
        finoBoxer_recorderCheckerEnable(finoBoxer_enable == 1)
    }
    
    @objc func import_event_register_calculate_checkout(_ arg: Any?) -> String {
        FinoBoxerData.finoBoxer_shared.finoBoxer_uuidString
    }
    
    @objc func evaluate_format_manage_transform_cancel_nature_event(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_enable = finoBoxer_info["enable"] as? Int
        else {
            return
        }
        
        UIApplication.shared.isIdleTimerDisabled = finoBoxer_enable == 1
    }
}

final class FinoBoxerManager: NSObject {
    init(
        finoBoxer_appUrl: String,
        finoBoxer_appConfig: FinoBoxerConfig,
        finoBoxer_showSplashViewAlert: @escaping FinoBoxerShowSplashViewAlert,
        finoBoxer_showRechargeAlert: @escaping FinoBoxerShowRechargeAlerAction
    ) {
        self.finoBoxer_appUrl = finoBoxer_appUrl
        self.finoBoxer_appConfig = finoBoxer_appConfig
        self.finoBoxer_showRechargeAlert = finoBoxer_showRechargeAlert
        self.finoBoxer_showSplashViewAlert = finoBoxer_showSplashViewAlert
        super.init()
        finoBoxer_registerNotificationTodayIfNotRegistered()
        
        finoBoxer_registerOneSignalWithOptions(FinoBoxerData.finoBoxer_shared.finoBoxer_notificationUserInfo)
//        finoboxer_loadWebView()
        if finoBoxer_lastIsLogined == true {
            finoBoxer_showSplash()
        }
        
        NetworkReachabilityManager.default?.startListening(
            onUpdatePerforming: { [weak self] status in
                switch status {
                case .reachable where self?.finoBoxer_isLoaded == false:
                    self?.finoBoxer_loadWebView()
                case .notReachable: break
//                    Task { @MainActor in
//                        finoboxer_showToast("Please check your network")
//                    }
                default: break
                }
            }
        )
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.finoBoxer_webView.callHandler("pageActive")
                //                self?.bazo_webView.configuration.allowsInlineMediaPlayback = true
                //                self?.bazo_webView.configuration.mediaTypesRequiringUserActionForPlayback = []
                //                self?.bazo_webView.configuration.preferences.javaScriptEnabled = true
                //                self?.bazo_webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
                //                self?.bazo_webView.reload()
                let script = """
                if (document.querySelector('video')) {
                    var video = document.querySelector('video');
                    if (video.paused) {
                        video.play();  // 如果视频暂停，则手动恢复播放
                    }
                }
                """
                self?.finoBoxer_webView.evaluateJavaScript(script, completionHandler: nil)
            }
        }
        
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 120)
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                    _ = FinoBoxerManager.finoBoxer_initAppsFlyer
                })
            }
        } else {
            _ = FinoBoxerManager.finoBoxer_initAppsFlyer
        }
    }
    
    static var finoBoxer_nowSecs: Int {
        TimeZone.current.secondsFromGMT(for: Date())
    }
    
    private lazy var finoBoxer_systemObject: FinoBoxerDispatcherSystem = .init(
        finoBoxer_appConfig: finoBoxer_appConfig,
        finoBoxer_rechargeSuccess: { [weak self] in
            guard let self else { return }
            self.finoBoxer_currentUserReceipts.append(
                .init(
                    finoBoxer_userId: self.finoBoxer_currentUserId ?? "",
                    finoBoxer_productId: $1,
                    finoBoxer_receiptString: $0
                )
            )
        },
        finoBoxer_showRechargeAlert: { [weak self] in
            // 三方充值
            self?.finoBoxer_showRechargeAlert($0, $1)
        },
        finoBoxer_appleBannerEnable: { [weak self] in
            // 白屏检测
            if $0 {
                self?.finoBoxer_webAppleBanner.finoBoxer_startCheck()
            } else {
                self?.finoBoxer_webAppleBanner.finoBoxer_stop()
            }
        },
        finoBoxer_recorderCheckerEnable: { [weak self] in
            // 录屏检测
            self?.finoBoxer_textField.isSecureTextEntry = $0
        },
        finoBoxer_logoutAction: { [weak self] in
            // 登出
            self?.finoBoxer_currentUserId = ""
            self?.finoBoxer_systemObject.finoBoxer_accountId = ""
            self?.finoBoxer_lastIsLogined = !"".isEmpty
        },
        finoBoxer_callJS: { [weak self] in
            self?.finoBoxer_webView.evaluateJavaScript($0)
        },
        finoBoxer_callhandler: { [weak self] finoBoxer_handlerName, finoBoxer_Args in
            self?.finoBoxer_webView.callHandler(finoBoxer_handlerName, arguments: [finoBoxer_Args])
        },
        finoBoxer_recharegeAction: { [weak self] finoBoxer_productId, finoBoxer_callback in
            self?.finoBoxer_payObject.finoBoxer_recharge(
                finoBoxer_productId,
                finoBoxer_callback: {
                    switch $0 {
                    case let .success(finoBoxer_receiptString):
                        finoBoxer_callback(finoBoxer_receiptString, true)
                    case .failure:
                        finoBoxer_callback("", false)
                    }
                }
            )
        }
    )
    static var finoBoxer_nowTs: TimeInterval {
        Date()
            .addingTimeInterval(Double(finoBoxer_nowSecs))
            .timeIntervalSince1970
    }
    
//    private var finoboxer_localServer: Server?
    
    private var finoBoxer_sinkCollection: Set<AnyCancellable> = []
    
    private(set) lazy var finoBoxer_displayView: UIView = {
        if #available(iOS 13.2, *), let finoBoxer_retValue = finoBoxer_textField.subviews.first {
            finoBoxer_textField.isEnabled = false
            finoBoxer_retValue.subviews.forEach { $0.removeFromSuperview() }
            finoBoxer_retValue.isUserInteractionEnabled = true
            return finoBoxer_retValue
        } else {
            return UIView()
        }
    }()
    
//    @Access<String?>(.userDefaults(.standard))
    @FinoBoxerDefaultPlistWrapper("finoboxer_currentUserId")
    private var finoBoxer_currentUserId: String?
    
    private let finoBoxer_textField = UITextField()
    
    let finoBoxer_appUrl: String
    typealias FinoBoxerShowSplashViewAlert = (FinoBoxerConfig.FinoBoxerOpenAdvertisings.FinoBoxerOpenAdvertisingsActivities, @escaping () -> Void) -> Void
    let finoBoxer_appConfig: FinoBoxerConfig
    
    private lazy var finoBoxer_payObject = FinoBoxerDispatcherPay(
        finoBoxer_receiptGetter: { [weak self] in
            self?.finoBoxer_currentUserReceipts.map(\.finoBoxer_receiptString) ?? []
        },
        finoBoxer_receiptSetter: { [weak self] in
            guard let self else { return }
            self.finoBoxer_currentUserReceipts = $0.map {
                .init(
                    finoBoxer_userId: self.finoBoxer_currentUserId ?? "",
                    finoBoxer_productId: "",
                    finoBoxer_receiptString: $0
                )
            }
        }
    )
    
    static let finoBoxer_initAppsFlyer: Void = {
        let appId: String = FinoBoxerViewData.finoBoxer_config!.finoBoxer_afId!
        let devKey: String = FinoBoxerViewData.finoBoxer_config!.finoBoxer_afKey!
        AppsFlyerLib.shared().appleAppID = appId
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().delegate = FinoBoxerAppsFlyerLibDelegate.finoBoxer_shared
        AppsFlyerLib.shared().start()
    }()

    typealias FinoBoxerShowRechargeAlerAction = (String, @escaping (Int) -> Void) -> Void
    
    private lazy var finoBoxer_webAppleBanner = FinoBoxerWebAppleBanner(finoBoxer_webView) { [weak self] in
        // reload webView
        if self?.finoBoxer_isLoaded == true {
            self?.finoBoxer_loadWebView()
        }
    }
    
    private lazy var finoBoxer_loginObject = FinoBoxerDispatcherLogin(finoBoxer_loginSuccessAction: { [weak self] finoBoxer_session, finoBoxer_accountId, _ in
        self?.finoBoxer_currentUserId = String(finoBoxer_accountId)
        self?.finoBoxer_systemObject.finoBoxer_accountId = String(finoBoxer_accountId)
        self?.finoBoxer_lastIsLogined = !String(finoBoxer_accountId).isEmpty
        self?.finoBoxer_session = finoBoxer_session
//        self?.finoboxer_loginMobileInfo(finoboxer_session)
        self?.finoBoxer_bindPushId(OneSignal.User.pushSubscription.id ?? "")
        self?.finoBoxer_handleRemoteNotificationIfCould()
        AppsFlyerLib.shared().customerUserID = String(finoBoxer_accountId)
        
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 120)
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                    _ = FinoBoxerManager.finoBoxer_initAppsFlyer
                })
            }
        } else {
            _ = FinoBoxerManager.finoBoxer_initAppsFlyer
        }
    })
    typealias FinoBoxerShowBlurViewAction = (Bool) -> Void
    
    @FinoBoxerDefaultPlistWrapper("finoboxer_session")
    private var finoBoxer_session: String?
    
    private var finoBoxer_currentUserReceipts: [FinoBoxerModel_Receipt] {
        get { finoBoxer_allReceipts.filter { $0.finoBoxer_userId == finoBoxer_currentUserId } }
        set {
            var finoBoxer_allReceiptsTemp = finoBoxer_allReceipts
            finoBoxer_allReceiptsTemp.removeAll(where: { $0.finoBoxer_userId == finoBoxer_currentUserId })
            finoBoxer_allReceiptsTemp.append(contentsOf: newValue.filter { !$0.finoBoxer_receiptString.isEmpty })
            finoBoxer_allReceipts = finoBoxer_allReceiptsTemp
        }
    }
    
    private lazy var finoBoxer_notificationStore = FinoBoxerNotificationStore(finoBoxer_appConfig: finoBoxer_appConfig)
    
    private var finoBoxer_allReceipts: [FinoBoxerModel_Receipt] {
        get {
            (
                try? UserDefaults.standard.finoBoxer_value(
                    "com.finoboxer.receipts",
                    finoBoxer_type: [FinoBoxerModel_Receipt].self
                )
            ) ?? []
        } set {
            try? UserDefaults.standard.finoBoxer_setValue("com.finoboxer.receipts", finoBoxer_value: newValue)
        }
    }
    
    @FinoBoxerDefaultPlistWrapper("finoboxer_lastIsLogined")
    private var finoBoxer_lastIsLogined: Bool?
    let finoBoxer_showSplashViewAlert: FinoBoxerShowSplashViewAlert
    let finoBoxer_showRechargeAlert: FinoBoxerShowRechargeAlerAction
    
    private lazy var finoBoxer_pageObject = FinoBoxerDispatcherPage { [weak self] in
        guard let self else { fatalError() }
        return self.finoBoxer_webView
    } finoBoxer_navigationbarEnable: { _ in
    }
    
    private var finoBoxer_isLoaded: Bool = false
    @FinoBoxerDefaultPlistWrapper("finoboxer_langCode")
    private var finoBoxer_langCode: String?
    
    private lazy var finoBoxer_storageObject = FinoBoxerDispatcherStorage()
   
    private(set) lazy var finoBoxer_webView: DWKWebView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsBackForwardNavigationGestures = true
        $0.scrollView.contentInsetAdjustmentBehavior = .never
        $0.scrollView.bounces = false
        $0.scrollView.bouncesZoom = false
        $0.scrollView.decelerationRate = .normal
//        let finoBoxer_runtimeHandler = DWKRunTimeHandler()
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_systemObject, forNamespace: "")
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_systemObject, forNamespace: "system")
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_loginObject, forNamespace: "loginAsyn")
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_pageObject, forNamespace: "page")
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_payObject, forNamespace: "payAsyn")
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_payObject, forNamespace: "recharge")
//        finoBoxer_runtimeHandler.dwk_addJavascriptObject(finoBoxer_storageObject, forNamespace: "storage")
        let finoBoxer_handlerMapper = FinoBoxerViewData.finoBoxer_mapper
        let finoBoxer_mapHandler = DWKSelMapHandler()
        finoBoxer_mapHandler.dwk_registerNamespace("", withTarget: finoBoxer_systemObject, withSelMap: finoBoxer_handlerMapper["", default: [:]])
        finoBoxer_mapHandler.dwk_registerNamespace("system", withTarget: finoBoxer_systemObject, withSelMap: finoBoxer_handlerMapper["system", default: [:]])
        finoBoxer_mapHandler.dwk_registerNamespace("loginAsyn", withTarget: finoBoxer_loginObject, withSelMap: finoBoxer_handlerMapper["loginAsyn", default: [:]])
        finoBoxer_mapHandler.dwk_registerNamespace("page", withTarget: finoBoxer_pageObject, withSelMap: finoBoxer_handlerMapper["page", default: [:]])
        finoBoxer_mapHandler.dwk_registerNamespace("payAsyn", withTarget: finoBoxer_payObject, withSelMap: finoBoxer_handlerMapper["payAsyn", default: [:]])
        finoBoxer_mapHandler.dwk_registerNamespace("recharge", withTarget: finoBoxer_payObject, withSelMap: finoBoxer_handlerMapper["recharge", default: [:]])
        finoBoxer_mapHandler.dwk_registerNamespace("storage", withTarget: finoBoxer_storageObject, withSelMap: finoBoxer_handlerMapper["storage", default: [:]])
        $0.dwk_eventHandler = finoBoxer_mapHandler
        #if DEBUG
        if #available(iOS 16.4, *) {
            $0.isInspectable = true
        }
        #endif
        self.finoBoxer_displayView.addSubview($0)
        $0.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return $0
    }(DWKWebView(frame: .zero, configuration: {
        $0.allowsInlineMediaPlayback = true
        $0.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
//        $0.preferences.javaScriptEnabled = true
        $0.defaultWebpagePreferences.allowsContentJavaScript = true
        $0.userContentController.add(self, name: "emit")
        return $0
    }(WKWebViewConfiguration())))

    private final class FinoBoxerNotificationStore {
        private let finoBoxer_queue = DispatchQueue(label: "com.finoboxer.notification.store.queue")
        private(set) var finoBoxer_notificationConfig: [String: Any] = [:]
        let finoBoxer_appConfig: FinoBoxerConfig
        init(finoBoxer_appConfig: FinoBoxerConfig) {
            self.finoBoxer_appConfig = finoBoxer_appConfig
            self.finoBoxer_notificationConfig = UserDefaults.standard.dictionary(forKey: "com.finoboxer.notification.config") ?? [:]
        }
                
        func finoBoxer_storeNotificationConfig(_ finoBoxer_config: [String: Any]) {
            finoBoxer_notificationConfig = finoBoxer_config
            UserDefaults.standard.setValue(finoBoxer_config, forKey: "com.finoboxer.notification.config")
        }
        
        func finoBoxer_getNotificationConfig(_ finoBoxer_completion: @escaping ([String: Any]) -> Void) {
            var finoBoxer_isCompleted = false
            if !finoBoxer_notificationConfig.isEmpty {
                finoBoxer_completion(finoBoxer_notificationConfig)
                finoBoxer_isCompleted = true
            }
            
            finoBoxer_queue.async { [weak self] in
                guard let self else { return }
                if let finoBoxer_url = URL(string: self.finoBoxer_appConfig.finoBoxer_tenNoteUrl) {
                    do {
                        let finoBoxer_data = try Data(contentsOf: finoBoxer_url)
                        if let finoBoxer_config = try JSONSerialization.jsonObject(with: finoBoxer_data, options: .fragmentsAllowed) as? [String: Any] {
                            self.finoBoxer_storeNotificationConfig(finoBoxer_config)
                            if !finoBoxer_isCompleted {
                                finoBoxer_completion(finoBoxer_config)
                            }
                        }
                    } catch {
                        debugPrint("download notification config failed error = \(error)")
                    }
                }
            }
        }
    }
    
    private func finoBoxer_getNotificationData(_ finoBoxer_config: [String: Any]) -> (triggerDate: Date, finoBoxer_title: String, subTitle: String) {
        let hour = finoBoxer_config["hour"] as? Int
        let minute = finoBoxer_config["minute"] as? Int
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateComponent = Date().components(dateSets: [.year, .month, .day])
        let dateString = String(
            format: "%04d-%02d-%02d %02d:%02d",
            dateComponent.year!,
            dateComponent.month!,
            dateComponent.day!,
            hour ?? 22,
            minute ?? 00
        )
//        let zone = NSTimeZone.system
//        let interval = zone.secondsFromGMT()
        let finoBoxer_date = dateFormatter.date(from: dateString)
        
        let triggerDate = finoBoxer_date ?? .distantFuture
        let finoBoxer_languageCode: [String: String] = [
            "en": "en",
            "ar": "ar",
            "tr": "tr"
        ]
        let finoBoxer_language = finoBoxer_langCode ?? ""
        let finoBoxer_code = finoBoxer_languageCode[finoBoxer_language] ?? "en"
        if let finoBoxer_configList = finoBoxer_config[finoBoxer_code] as? [[String: String]] {
            let randomIndex = Int(arc4random()) % finoBoxer_configList.count
            let titleConfig = finoBoxer_configList[randomIndex]
            let finoBoxer_title = titleConfig["title"]
            let subtitle = titleConfig["content"]
            return (
                triggerDate: triggerDate,
                finoBoxer_title: finoBoxer_title ?? "",
                subTitle: subtitle ?? ""
            )
        }
        return (
            triggerDate: triggerDate,
            finoBoxer_title: "",
            subTitle: ""
        )
    }
    
    func finoBoxer_webViewDidLoad() {
        finoBoxer_isLoaded = true
        if finoBoxer_lastIsLogined == true {
            finoBoxer_bindPushId(OneSignal.User.pushSubscription.id ?? "")
//            finoboxer_handleRemoteNotificationIfCould()
        }
    }
    
    private func finoBoxer_registerNotificationWithAuthorizion(_ finoBoxer_config: [String: Any]) {
        let (triggerDate, finoBoxer_title, subTitle) = finoBoxer_getNotificationData(finoBoxer_config)
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: ["com.finoboxer.local.notification"]
            )
        
        let finoBoxer_content = UNMutableNotificationContent()
        finoBoxer_content.title = finoBoxer_title
        finoBoxer_content.sound = .default
        finoBoxer_content.body = subTitle
        if triggerDate.timeIntervalSinceNow > 10 {
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: triggerDate.timeIntervalSinceNow,
                repeats: false
            )
            let finoBoxer_request = UNNotificationRequest(
                identifier: "com.finoboxer.local.notification",
                content: finoBoxer_content,
                trigger: trigger
            )
            UNUserNotificationCenter.current()
                .add(finoBoxer_request) { _ in
                    // print("register local notification error = \(String(describing: $0))")
                }
        }
        UserDefaults.standard.setValue(
            Date().timeIntervalSince1970,
            forKey: "com.finoboxer.last.notification.register.date"
        )
    }
    
    private func finoBoxer_registerOneSignalWithOptions(_ finoBoxer_notificationUserInfo: [AnyHashable: Any]?) {
        FinoBoxerUNNotificationDelegate.finoBoxer_default.finoBoxer_didReceiveRemoteNotification = { [weak self] _ in
            guard self?.finoBoxer_isLoaded == true else { return }
            self?.finoBoxer_handleRemoteNotificationIfCould()
        }
        
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { r, _ in
                    if r {
                        debugPrint("通知权限开启")
                    }
                }
            )
        
        UNUserNotificationCenter.current().delegate = FinoBoxerUNNotificationDelegate.finoBoxer_default
            
        if let finoBoxer_notificationUserInfo = finoBoxer_notificationUserInfo as? [String: Any] {
            FinoBoxerUNNotificationDelegate.finoBoxer_default.finoBoxer_userInfo = finoBoxer_notificationUserInfo
        }
    }
    
    private func finoBoxer_handleRemoteNotificationIfCould() {
        if !FinoBoxerUNNotificationDelegate.finoBoxer_default.finoBoxer_userInfo.isEmpty {
            finoBoxer_push(FinoBoxerUNNotificationDelegate.finoBoxer_default.finoBoxer_userInfo)
            FinoBoxerUNNotificationDelegate.finoBoxer_default.finoBoxer_userInfo = [:]
        }
    }
    
    private func finoBoxer_registerNotificationTodayIfNotRegistered() {
        let finoBoxer_dateTimeinterval = UserDefaults.standard.double(forKey: "com.finoboxer.last.notification.register.date")
        let finoBoxer_date = Date(timeIntervalSince1970: finoBoxer_dateTimeinterval)
//        PlistDictionary.finoboxer_main.value(for: String.finoboxer_lastNotificationRegisteredDate, with: Date.self)
        var finoBoxer_shouldRegister = true
        if finoBoxer_date.isDayEqual(Date()) {
            finoBoxer_shouldRegister = false
        }
        
        if finoBoxer_shouldRegister {
            finoBoxer_notificationStore.finoBoxer_getNotificationConfig { [weak self] finoBoxer_config in
                self?.finoBoxer_registerNotification(finoBoxer_config)
            }
        }
    }
    
    private func finoBoxer_showSplash() {
        let finoBoxer_isEnable = finoBoxer_appConfig.finoBoxer_openAdvertising?.finoBoxer_enable?.boolValue ?? false
        let finoBoxer_ads = finoBoxer_appConfig.finoBoxer_openAdvertising?.finoBoxer_activities ?? []
        guard finoBoxer_isEnable, !finoBoxer_ads.isEmpty else { return }
        let finoBoxer_random = Int(arc4random()) % finoBoxer_ads.count
        let finoBoxer_ad = finoBoxer_ads[finoBoxer_random]
        finoBoxer_showSplashViewAlert(finoBoxer_ad) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.finoBoxer_splashAction(
                    finoBoxer_ad.finoBoxer_imageUrl,
                    finoBoxer_addressUrl: finoBoxer_ad.finoBoxer_addressUrl
                )
            }
        }
        finoBoxer_logEvent("loading_open_ads")
    }
    
    final class FinoBoxerUNNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        static let finoBoxer_default = FinoBoxerUNNotificationDelegate()
        
        var finoBoxer_userInfo: [String: Any] = [:]
        
        typealias FinoBoxerDidReceiveRemoteNotification = ([String: Any]) -> Void
        var finoBoxer_didReceiveRemoteNotification: FinoBoxerDidReceiveRemoteNotification?
        
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            if #available(iOS 14.0, *) {
                completionHandler([.sound, .banner, .badge])
            } else {
                // Fallback on earlier versions
                completionHandler([.sound, .alert, .badge])
            }
        }
    }
    
    func finoBoxer_logEvent(_ finoBoxer_eventName: String) {
        let finoBoxer_properties: [String: Any] = [
            "app_name": FinoBoxerViewData.finoBoxer_config!.finoBoxer_appName!,
            "app_channel": FinoBoxerViewData.finoBoxer_config!.finoBoxer_channelId!,
            "#zone_offset": Int(TimeZone.current.secondsFromGMT() / 3600)
        ]

        #if DEBUG
        let finoBoxer_isDebug = 1
        #else
        let finoBoxer_isDebug = 0
        #endif
//        NSInteger zone = NSTimeZone.localTimeZone.secondsFromGMT / 3600;
//        [properties setValue:@(zone) forKey:@"#zone_offset"];
        let finoBoxer_body: [String: Any] = [
            "debug": finoBoxer_isDebug,
            "appid": "",
            "data": [
                "#time": Date().serializeToString("yyyy-MM-dd HH:mm:ss"),
                "#type": "track",
                "#event_name": finoBoxer_eventName,
                "#account_id": finoBoxer_currentUserId ?? "",
                "properties": finoBoxer_properties,
                "#distinct_id": FinoBoxerData.finoBoxer_shared.finoBoxer_uuidString
            ]
        ]
        // 请求
        let url = finoBoxer_appConfig.finoBoxer_thinkingUrl + "/sync_json"
        let finoBoxer_requestHeader = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "client": "1"
        ]
        
        Session.default.request(
            url,
            method: .post,
            parameters: finoBoxer_body,
            headers: HTTPHeaders(finoBoxer_requestHeader.map { .init(name: $0.key, value: $0.value) })
        )
        .response { _ in
            debugPrint("---------- 数数统计 \(finoBoxer_body)")
        }
        .resume()
    }
    
    func finoBoxer_bindPushId(_ finoBoxer_pushId: String) {
        finoBoxer_webView.callHandler(
            "pushOneSignal",
            arguments: [["oneSignalUserId": finoBoxer_pushId]],
            completionHandler: {
                debugPrint("绑定oneSingalId \(String(describing: $0))")
            }
        )
    }
    
    private func finoBoxer_registerNotification(_ finoBoxer_config: [String: Any]) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { [weak self] r, _ in
                if r {
                    self?.finoBoxer_registerNotificationWithAuthorizion(finoBoxer_config)
                }
            }
        )
    }
    
    func finoBoxer_push(_ finoBoxer_notification: [String: Any]) {
        guard JSONSerialization.isValidJSONObject(finoBoxer_notification) else { return }
        if let finoBoxer_data = try? JSONSerialization.data(withJSONObject: finoBoxer_notification),
           let finoBoxer_string = String(data: finoBoxer_data, encoding: .utf8)
        {
            finoBoxer_webView.callHandler("push", arguments: [finoBoxer_string])
        }
    }
    
    // MARK: - - private

    func finoBoxer_loadWebView() {
        finoBoxer_isLoaded = false
        if var finoBoxer_urlComponents = URLComponents(string: finoBoxer_appUrl) {
            let finoBoxer_random = Int(arc4random() % 1000000 + 100000)
            finoBoxer_urlComponents.queryItems?.append(.init(name: "t", value: String(finoBoxer_random)))
            if let finoBoxer_appURL = finoBoxer_urlComponents.url {
                DispatchQueue.main.async {
                    self.finoBoxer_webView.load(
                        URLRequest(
                            url: finoBoxer_appURL,
                            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
                        )
                    )
                }
            }
        }
    }
    
    private final class FinoBoxerAppsFlyerLibDelegate: NSObject, AppsFlyerLibDelegate {
        static let finoBoxer_shared = FinoBoxerAppsFlyerLibDelegate()
        
        func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
            do {
                let finoBoxer_json = try JSONSerialization.data(withJSONObject: conversionInfo, options: .prettyPrinted)
                debugPrint("\(#function) \(String(data: finoBoxer_json, encoding: .utf8) ?? "")")
            } catch {
                debugPrint(#function)
            }
        }
        
        func onConversionDataFail(_ error: Error) {
            debugPrint("\(#function) \(error)")
        }
    }
    
    func finoBoxer_splashAction(
        _ finoBoxer_imageUrl: String,
        finoBoxer_addressUrl: String
    ) {
        let finoBoxer_dict = [
            "imageUrl": finoBoxer_imageUrl,
            "addressUrl": finoBoxer_addressUrl
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.finoBoxer_webView.callHandler("splash", arguments: [finoBoxer_dict])
        }
    }
}

final class FinoBoxerDispatcherStorage: NSObject {
    var finoBoxer_storage: [String: String] {
        get { (UserDefaults.standard.dictionary(forKey: "com.finoboxer.object.storage") as? [String: String]) ?? [:] }
        set { UserDefaults.standard.setValue(newValue, forKey: "com.finoboxer.object.storage") }
    }

    @objc func encode_handle(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_key = finoBoxer_info["key"] as? String
        else {
            return
        }
        finoBoxer_storage[finoBoxer_key] = nil
    }
    
    @objc func calculate_sort_profile(_ arg: Any?) {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_key = finoBoxer_info["key"] as? String,
              let finoBoxer_value = finoBoxer_info["value"] as? String
        else {
            return
        }
        finoBoxer_storage[finoBoxer_key] = finoBoxer_value
    }
    
    @objc func handle_garden(_ arg: Any?) {
        finoBoxer_storage = [:]
    }
    
    @objc func garden_dragon_evaluate(_ arg: Any?) -> String {
        guard let finoBoxer_info = arg as? [String: Any],
              let finoBoxer_key = finoBoxer_info["key"] as? String
        else {
            return ""
        }
        return finoBoxer_storage[finoBoxer_key] ?? ""
    }
}

extension UserDefaults {
    func finoBoxer_setValue<T: Encodable>(
        _ finoBoxer_key: String,
        finoBoxer_value: T?,
        finoBoxer_using: JSONEncoder = .init()
    ) throws {
        if let finoBoxer_value {
            let finoBoxer_data = try finoBoxer_using.encode(finoBoxer_value)
            UserDefaults.standard.setValue(finoBoxer_data, forKey: finoBoxer_key)
        } else {
            UserDefaults.standard.removeObject(forKey: finoBoxer_key)
        }
    }

    func finoBoxer_value<T: Decodable>(
        _ finoBoxer_key: String,
        finoBoxer_type: T.Type,
        finoBoxer_using: JSONDecoder = .init()
    ) throws -> T? {
        if let finoBoxer_data = UserDefaults.standard.data(forKey: finoBoxer_key) {
            return try finoBoxer_using.decode(finoBoxer_type, from: finoBoxer_data)
        }
        return nil
    }
}

extension FinoBoxerManager: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        finoBoxer_systemObject.finoBoxer_returnTDIfNeeded()
        finoBoxer_systemObject.finoBoxer_retrunIdFA()
        guard message.name == "emit",
              let finoBoxer_jsonString = message.body as? String,
              let finoBoxer_jsonData = finoBoxer_jsonString.data(using: .utf8)
        else {
            return
        }
        do {
            let finoBoxer_emitJSON = try JSONSerialization.jsonObject(
                with: finoBoxer_jsonData,
                options: .mutableContainers
            ) as? [String: Any]
            
            if let finoBoxer_body = finoBoxer_emitJSON?["body"] as? [String: Any] {
//                finoBoxer_callhandler("track", finoBoxer_params)
                finoBoxer_systemObject.dragon(finoBoxer_body["params"])
            }
        } catch {
            print(error)
        }
    }
}

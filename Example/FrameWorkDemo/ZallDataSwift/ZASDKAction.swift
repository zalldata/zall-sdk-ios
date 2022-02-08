//
//  ZASDKAction.swift
//  ZallDataSwift
//
//  Created by Mac on 2022/1/27.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

import UIKit
import ZallDataSDK

class ZASDKAction: NSObject {
    private var list:Array<Dictionary> = sdkDataList()
    
    static func sdkActionWithDataList(_ list:Array<Any>?)->ZASDKAction{
        let action = ZASDKAction()
        if (list != nil) {
            action.list = list! as! Array<Dictionary>
        }
         
        return action
    }
   
    
    var count: Int {
        list.count
    }
    
    func cellForWithRow(_ row:Int) -> String {
        let dic:Dictionary = list[row]
        return dic.first!.key
    }
    
    func cellForSelectWithRow(_ row:Int,withBlock block:(_ action:ZASDKAction)->()) {
        let dic:Dictionary = list[row]
        let value = dic.first?.value
        if value is Array<Any>  {
            block(ZASDKAction.sdkActionWithDataList((value as! Array<Any>)))
        }else{
            
            let ls:(() -> Void)? = value as? () -> Void
            if ls != nil {
                ls!()
            }
            
            
            
            
        }
    }
    
    
    
    
    
}


extension ZASDKAction{
    class func sdkDataList()->Array<Dictionary<String, Any>>{
        return [
            ["公共属性"     :publicAttribute()],
            ["loginId"    :loginId()],
            ["匿名ID"      :anonymousID()],
            ["Bind"       :bind()],
            ["Item"       :item()],
            ["UserProfile":userProfile()],
            ["TrackTimer" :trackTimer()],
            ["track event":trackEvent()],
            ["TrackView"  :trackView()],
            ["渠道"        :trackChannel()],
            ["DebugMode"  :debugMode()],
            ["Deeplink"   :deeplink()],
            ["设备方向"     :screenOrientation()],
            ["JavaScript" :javascript()],
            ["Location"   :location()],
            ["远程配置"     :remoteConfig()],
            ["可视化"      :visualized()],
            ["HeatMap"    :heatMap()],
            
        ]
    }
    class func actionBlock(_ block:@escaping (()->Void))-> (()->Void){
        return block
    }
    
    class func publicAttribute()->Array<Any>{
        return  [
            ["返回预制的属性":self.actionBlock {
                print(SharedZallDataSDK()?.getPresetProperties() as Any)
            }],
            ["注册公共属性": self.actionBlock{
                SharedZallDataSDK()?.registerSuperProperties(["key_first":"value_first"])
            }],
            ["动态公共属性": self.actionBlock{
                SharedZallDataSDK()?.registerDynamicSuperProperties({
                    ["key_dy_first":"value_dy_first"]
                })
            }],
            ["注销公共属性": self.actionBlock{
                SharedZallDataSDK()?.unregisterSuperProperty("key_first")
            }],
            ["清空公共属性": self.actionBlock{
                SharedZallDataSDK()?.clearSuperProperties()
            }],
            ["获取当前公共属性": self.actionBlock{
                print(SharedZallDataSDK()?.currentSuperProperties() as Any);
            }]
        ]
    }
    
    class func loginId()->Array<Any>{
        return  [
            ["设置当前用户的 loginId":self.actionBlock{
                SharedZallDataSDK()?.login("1234567890")
                
            }],
            ["获取当前用户ID":self.actionBlock{
                print(SharedZallDataSDK()?.loginId() as Any)
            }],
            ["当前用户的 loginId 并添加扩招属性":self.actionBlock{
                SharedZallDataSDK()?.login("987654321", withProperties: ["username":"555"])
            }],
            ["注销，清空当前用户的 loginId":self.actionBlock{
                SharedZallDataSDK()?.logout()
            }],
        ]
    }
    class func anonymousID()->Array<Any>{
        return [
            ["获取用户的唯一用户标识":self.actionBlock{
                print(SharedZallDataSDK()?.distinctId() as Any)
            }],
            ["获取匿名 id":self.actionBlock{
                print(SharedZallDataSDK()?.anonymousId() as Any)
            }],
            ["重置默认匿名 id":self.actionBlock{
                SharedZallDataSDK()?.resetAnonymousId()
                    
            }],
            ["指定匿名ID":self.actionBlock{
                SharedZallDataSDK()?.identify("123123")
            }]
        ]
    }
    
    class func bind()->Array<Any>{
        return [
            ["绑定":self.actionBlock{
                SharedZallDataSDK()?.bind("bind_key", value: "bind_value")
            }],
            ["解绑":self.actionBlock{
                SharedZallDataSDK()?.bind("bing_key", value: "bind_value")
            }]
            
        ]
    }
    class func item()->Array<Any>{
        return [
            ["设置 item":self.actionBlock{
                SharedZallDataSDK()?.itemSet(withType: "itme", itemId: "1", properties: ["name1":"Item1","name2":"Item2"])
                
            }],
            ["删除 item":self.actionBlock{
                SharedZallDataSDK()?.itemDelete(withType: "item", itemId: "1")
                
            }]
        ]
    }
    class func userProfile()->Array<Any>{
        return [
            ["设置用户的一个或者几个 Profiles":self.actionBlock{
                SharedZallDataSDK()?.set([
                    "Profiles1":"Profiles1",
                    "Profiles2":[
                        "Profiles2_1":"Profiles2_1"
                    ]
                ])
                
            }],
            ["设置用户的pushId":self.actionBlock{
                SharedZallDataSDK()?.profilePushKey("pushkey1", pushId: "pushId1")
            }],
            ["删除用户设置的 pushId":self.actionBlock{
                SharedZallDataSDK()?.profileUnsetPushKey("pushId1")
            }],
            ["首次设置用户Profiles":self.actionBlock{
                SharedZallDataSDK()?.setOnce([
                    "Profiles1":"Profiles1",
                    "Profiles2":[
                        "Profiles2_1":"Profiles2_1"
                    ]
                ])
            }],
            ["设置用户的单个 Profile":self.actionBlock{
                SharedZallDataSDK()?.set("Profiles1", to: [
                    "Profiles1":"Profiles1",
                    "Profiles2":[
                        "Profiles2_1":"Profiles2_1"
                    ]
                ])
            }],
            ["首次设置用户的单个 Profile 的内容":self.actionBlock{
                SharedZallDataSDK()?.setOnce("OnceProfiles1", to: [
                    "Profiles1":"Profiles1",
                    "Profiles2":[
                        "Profiles2_1":"Profiles2_1"
                    ]
                ])
            }],
            ["删除某个 Profile 的全部内容":self.actionBlock{
                SharedZallDataSDK()?.unset("Profiles1")
            }],
            ["给一个数值类型的 Profile 增加一个数值":self.actionBlock{
                SharedZallDataSDK()?.increment("increment", by: 1)
            }],
            
            ["给多个数值类型的 Profile 增加数值":self.actionBlock{
                SharedZallDataSDK()?.increment([
                    "increment1":1,
                    "increment2":2])
            }],
            ["向一个 NSSet 或者 NSArray 类型的 value 添加值":self.actionBlock{
                let ser:NSArray = ["append1","append2"]
                SharedZallDataSDK()?.append("append", by:ser)
            }],
            ["删除当前这个用户的所有记录":self.actionBlock{
                SharedZallDataSDK()?.deleteUser()
            }],
            
            
            
            ["清除 keychain 缓存数据":self.actionBlock{
                SharedZallDataSDK()?.clearKeychainData()
            }],

            ["获取最后设置的属性":self.actionBlock{
                print(SharedZallDataSDK()?.getLastScreenTrackProperties() as Any)
            }]
            
        ]
    }
    class func trackTimer()->Array<Any>{
        return [
            ["开始事件计时":self.actionBlock{
                print(SharedZallDataSDK()?.trackTimerStart("time_track_01") as Any)
                
            }],
            ["暂停事件计时":self.actionBlock{
                SharedZallDataSDK()?.trackTimerPause("time_track_01")
                
            }],
            ["恢复事件计时":self.actionBlock{
                SharedZallDataSDK()?.trackTimerResume("time_track_01")
            }],
            ["结束事件计时有参":self.actionBlock{
                SharedZallDataSDK()?.trackTimerEnd("time_track_01", withProperties: ["time_end":"time_end"])
            }],
            ["结束事件计时":self.actionBlock{
                SharedZallDataSDK()?.trackTimerEnd("time_track_01")
            }],
            ["删除事件计时":self.actionBlock{
                SharedZallDataSDK()?.trackRemoveTimer("time_track_01")
            }],
            ["清除所有事件计时器":self.actionBlock{
                SharedZallDataSDK()?.clearTrackTimer()
            }]
        ]
    }
    class func trackEvent()->Array<Any>{
        return [
            ["Track App Extension groupIdentifier 中缓存的数据":self.actionBlock{
                SharedZallDataSDK()?.trackEventFromExtension(withGroupIdentifier: "11", completion: { groupIdentifier, events in
                    print(groupIdentifier)
                    print(events)
                })
            }],
            ["修改入库之前的事件属性":self.actionBlock{
                SharedZallDataSDK()?.trackEventWillSave({ eventName, properties in
                    print(properties)
                    return true
                })
            }],
            ["调用 track":self.actionBlock{
                SharedZallDataSDK()?.track("event_01")
            }],
            ["调用 track 有属性":self.actionBlock{
                SharedZallDataSDK()?.track("event_01", withProperties: ["time_end":"time_end"])
            }],
            ["强制上传埋点事件":self.actionBlock{
                SharedZallDataSDK()?.trackForceSendAll()
            }],
            ["删除本地所有缓存事件":self.actionBlock{
                SharedZallDataSDK()?.trackDeleteAll()
            }]
        ]
    }
    class func trackView()->Array<Any>{
        return [
            ["是否开启 AutoTrack":self.actionBlock{
                print(SharedZallDataSDK()?.isAutoTrackEnabled() as Any)
            }],
            ["通过代码触发 UIView 的 $AppClick 事件":self.actionBlock{
                SharedZallDataSDK()?.trackViewAppClick(rootViewController().view)
            }],
            ["通过代码触发  $AppViewScreen":self.actionBlock{
                SharedZallDataSDK()?.trackViewScreen(rootViewController())
            }],
            ["通过代码触发  $AppViewScreen properties":self.actionBlock{
                SharedZallDataSDK()?.trackViewScreen(rootViewController(), properties: ["propertiestrackViewScreen":"propertiestrackViewScreen"])
            }],
            ["通过代码触发  $AppViewScreen 通过url":self.actionBlock{
                SharedZallDataSDK()?.trackViewScreen("url", withProperties: ["AppViewScreen":"AppViewScreen"])
            }]
        ]
    }
    class func trackChannel()->Array<Any>{
        return [
            ["track 渠道":self.actionBlock{
                SharedZallDataSDK()?.trackChannelEvent("channel1")
            }],
            ["track 渠道 加参":self.actionBlock{
                SharedZallDataSDK()?.trackChannelEvent("channel2", properties: ["channel2":"channel2"])
            }],
            ["App 首次启动时追踪渠道来源":self.actionBlock{
                SharedZallDataSDK()?.trackAppInstall()
            }],
            ["App 首次启动时追踪渠道来源 填入事件属性 $utm_ 开头的一系列属性中":self.actionBlock{
                SharedZallDataSDK()?.trackAppInstall(withProperties: ["appinstall":"appinstall"])
            }],
            ["App 首次启动时追踪渠道来源 ":self.actionBlock{
                SharedZallDataSDK()?.trackAppInstall(withProperties: ["properties":"properties"], disableCallback:true)
            }],
            ["App 首次启动时追踪渠道来源 自定义事件":self.actionBlock{
                SharedZallDataSDK()?.trackInstallation("aaa")
            }],
            ["App 首次启动时追踪渠道来源 自定义属性 ":self.actionBlock{
                SharedZallDataSDK()?.trackInstallation("aaa", withProperties: ["pro":"pro"])
            }],
            ["App 首次启动时追踪渠道来源 自定义属性":self.actionBlock{
                SharedZallDataSDK()?.trackInstallation("aaa", withProperties: ["properties":"properties"], disableCallback: true)
            }]
        ]
    }
    
    class func debugMode()->Array<Any>{
        return [
            ["设置是否显示 debugInfoView":self.actionBlock{
                SharedZallDataSDK()?.showDebugInfoView(true)
            }]
        ]
    }
    
    class func deeplink()->Array<Any>{
        return [
            ["DeepLink 回调函数":self.actionBlock{
                SharedZallDataSDK()?.setDeeplinkCallback({ params, success, appAwake in
                    print(params as Any)
                    print(success as Any)
                    print(appAwake as Any)
                })
            }],
            ["触发 $AppDeepLinkLaunch 事件":self.actionBlock{
                SharedZallDataSDK()?.trackDeepLinkLaunch(withURL: "appdelinkLaunch")
            }]
        ]
    }
    class func screenOrientation()->Array<Any>{
        return [
            ["设备方向 开关":self.actionBlock{
                SharedZallDataSDK()?.enableTrackScreenOrientation(true)
            }]
        ]
    }
    class func javascript()->Array<Any>{
        return [
            ["WKWebView":self.actionBlock{
                getCurrentViewController()?.navigationController?.pushViewController(ZAWebViewController(), animated: true)
            }],
            ["H5 数据打通的时候默认通过 ServerUrl 校验":self.actionBlock{
                SharedZallDataSDK()?.addWebViewUserAgentZallDataFlag()
            }],
            ["H5 数据打通的时候是否校验":self.actionBlock{
                SharedZallDataSDK()?.addWebViewUserAgentZallDataFlag(true)
            }],
            ["H5 数据打通的时候是否校验UserAgent":self.actionBlock{
                SharedZallDataSDK()?.addWebViewUserAgentZallDataFlag(true, userAgent: "")
            }],
            ["将 distinctId 传递给当前的 WebView":self.actionBlock{
                SharedZallDataSDK()?.showUpWebView(WKWebView(), with: NSURLRequest() as URLRequest)
            }],
            ["将 distinctId 传递给当前的 WebView 验证":self.actionBlock{
                SharedZallDataSDK()?.showUpWebView(WKWebView(), with: NSURLRequest() as URLRequest,enableVerify: true)
            }],
            ["将 distinctId 传递给当前的 WebView 扩展属性":self.actionBlock{
                SharedZallDataSDK()?.showUpWebView(WKWebView(), with: NSURLRequest() as URLRequest,andProperties: ["properties":"prooerties"])
            }],
            ["桥接h5事件上传":self.actionBlock{
                SharedZallDataSDK()?.trackFromH5(withEvent: "trackFromH5WithEvent")
            }],
            ["桥接h5事件上传 验证":self.actionBlock{
                SharedZallDataSDK()?.trackFromH5(withEvent: "trackFromH5WithEvent")
                SharedZallDataSDK()?.trackFromH5(withEvent: "trackFromH5WithEvent", enableVerify: true)
            }]
            
            
        ]
    }
    
    class func location()->Array<Any>{
        return [
            ["位置信息采集开关":self.actionBlock{
                SharedZallDataSDK()?.enableTrackGPSLocation(true)
            }]
        ]
    }
    
    class func remoteConfig()->Array<Any>{
        return [
            ["请求远程配置":self.actionBlock{
                ZallDataSDK.updateServerUrl("url", isRequestRemoteConfig: false)
            }],
            ["发起请求远程配置":self.actionBlock{
                ZallDataSDK.updateRemoteConfigServerRequest()
            }]
        ]
    }
    
    class func visualized()->Array<Any>{
        return [
            ["是否开启":self.actionBlock{
                print(SharedZallDataSDK()?.isVisualizedAutoTrackEnabled() as Any)
            }],
            ["指定哪些页面开启 可视化全埋点 分析":self.actionBlock{
                SharedZallDataSDK()?.addVisualizedAutoTrackViewControllers(["classname"])
            }],
            ["指定哪些页面开启 可视化全埋点 分析":self.actionBlock{
                SharedZallDataSDK()?.isVisualizedAutoTrackViewController(rootViewController())
            }]
        ]
    }
    
    class func heatMap()->Array<Any>{
        return [
            ["是否开启":self.actionBlock{
                print(SharedZallDataSDK()?.isVisualizedAutoTrackEnabled() as Any)
            }],
            ["指定哪些页面开启 HeatMap分析":self.actionBlock{
                SharedZallDataSDK()?.addHeatMapViewControllers(["classname"])
            }],
            ["某个页面是否开启 点击图  分析":self.actionBlock{
                SharedZallDataSDK()?.isHeatMapViewController(rootViewController())
            }]
        ]
    }
    
}
extension ZASDKAction{
    class func getCurrentViewController() -> UIViewController?{
        // 获取当先显示的window
        var currentWindow = UIApplication.shared.keyWindow ?? UIWindow()
        if currentWindow.windowLevel != UIWindow.Level.normal {
            let windowArr = UIApplication.shared.windows
            for window in windowArr {
                if window.windowLevel == UIWindow.Level.normal {
                    currentWindow = window
                    break
                }
            }
        }
        return getNextXController(nextController: currentWindow.rootViewController)
    }
        
    private class func  getNextXController(nextController: UIViewController?) -> UIViewController? {
        if nextController == nil {
            return nil
        }else if nextController?.presentedViewController != nil {
            return getNextXController(nextController: nextController?.presentedViewController)
        }else if let tabbar = nextController as? UITabBarController {
            return getNextXController(nextController: tabbar.selectedViewController)
        }else if let nav = nextController as? UINavigationController {
            return getNextXController(nextController: nav.visibleViewController)
        }
        return nextController
    }
}

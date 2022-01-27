Pod::Spec.new do |s|
  s.name         = "ZallDataSDK"
  s.version      = "0.0.1"
  s.summary      = "The official iOS SDK of zall Digital."
  s.homepage     = "https://www.zalldigital.cn"
  s.source       = { :git => 'http://git.zalldigital.cn/z-data/z-data-ios-sdk.git', :tag => "v#{s.version}" } 
  s.license = { :type => "Apache License, Version 2.0" }
  s.author = { "Guo" => "guozhentao@zalldigital.com" }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.default_subspec = 'Core'
  s.frameworks = 'Foundation', 'SystemConfiguration'

  s.libraries = 'icucore', 'sqlite3', 'z'

  s.subspec 'Base' do |b|
    core_dir = "ZallDataSDK/Core/"
    b.source_files = core_dir + "**/*.{h,m}"
    b.exclude_files = core_dir + "ZAAlertController.h", core_dir + "ZAAlertController.m"
    b.public_header_files = core_dir + "ZallDataSDK.h", core_dir + "ZallDataSDK+Public.h", core_dir + "ZAAppExtensionDataManager.h", core_dir + "ZASecurityPolicy.h", core_dir + "ZAConfigOptions.h", core_dir + "ZAConstants.h"
    b.ios.resource = 'ZallDataSDK/ZallDataSDK.bundle'
    b.ios.frameworks = 'CoreTelephony'
  end

  s.subspec 'Extension' do |e|
    e.dependency 'ZallDataSDK/Base'
  end

  s.subspec 'Common' do |c|
    c.dependency 'ZallDataSDK/Extension'
    c.public_header_files = 'ZallDataSDK/JSBridge/ZallDataSDK+JavaScriptBridge.h'
    c.source_files = 'ZallDataSDK/Core/ZAAlertController.{h,m}', 'ZallDataSDK/JSBridge/**/*.{h,m}'
    c.ios.source_files = 'ZallDataSDK/RemoteConfig/**/*.{h,m}', 'ZallDataSDK/ChannelMatch/**/*.{h,m}', 'ZallDataSDK/Encrypt/**/*.{h,m}', 'ZallDataSDK/Deeplink/**/*.{h,m}', 'ZallDataSDK/DebugMode/**/*.{h,m}', 'ZallDataSDK/Core/ZAAlertController.h'
    c.ios.public_header_files = 'ZallDataSDK/{Encrypt,RemoteConfig,ChannelMatch,Deeplink,DebugMode}/{ZAConfigOptions,ZallDataSDK}+*.h', 'ZallDataSDK/Encrypt/ZAEncryptProtocol.h', 'ZallDataSDK/Encrypt/ZASecretKey.h'
  end
  
  s.subspec 'Core' do |c|
    c.ios.dependency 'ZallDataSDK/Visualized'
    c.osx.dependency 'ZallDataSDK/Common'
  end

  # 支持 CAID 渠道匹配
  s.subspec 'CAID' do |f|
    f.ios.deployment_target = '8.0'
    f.dependency 'ZallDataSDK/Core'
    f.source_files = "ZallDataSDK/CAID/**/*.{h,m}"
    f.private_header_files = 'ZallDataSDK/CAID/**/*.h'
  end

  # 全埋点
  s.subspec 'AutoTrack' do |g|
    g.ios.deployment_target = '8.0'
    g.dependency 'ZallDataSDK/Common'
    g.source_files = "ZallDataSDK/AutoTrack/**/*.{h,m}"
    g.public_header_files = 'ZallDataSDK/AutoTrack/ZallDataSDK+ZAAutoTrack.h', 'ZallDataSDK/AutoTrack/ZAConfigOptions+AutoTrack.h'
    g.frameworks = 'UIKit'
  end

# 可视化相关功能，包含可视化全埋点和点击图
  s.subspec 'Visualized' do |f|
    f.ios.deployment_target = '8.0'
    f.dependency 'ZallDataSDK/AutoTrack'
    f.source_files = "ZallDataSDK/Visualized/**/*.{h,m}"
    f.public_header_files = 'ZallDataSDK/Visualized/ZallDataSDK+Visualized.h', 'ZallDataSDK/Visualized/ZAConfigOptions+Visualized.h'
  end

  # 开启 GPS 定位采集
  s.subspec 'Location' do |f|
    f.ios.deployment_target = '8.0'
    f.frameworks = 'CoreLocation'
    f.dependency 'ZallDataSDK/Core'
    f.source_files = "ZallDataSDK/Location/**/*.{h,m}"
    f.public_header_files = 'ZallDataSDK/Location/ZallDataSDK+Location.h'
  end

  # 开启设备方向采集
  s.subspec 'DeviceOrientation' do |f|
    f.ios.deployment_target = '8.0'
    f.dependency 'ZallDataSDK/Core'
    f.source_files = 'ZallDataSDK/DeviceOrientation/**/*.{h,m}'
    f.public_header_files = 'ZallDataSDK/DeviceOrientation/ZallDataSDK+DeviceOrientation.h'
    f.frameworks = 'CoreMotion'
  end

  # 推送点击
  s.subspec 'AppPush' do |f|
    f.ios.deployment_target = '8.0'
    f.dependency 'ZallDataSDK/Core'
    f.source_files = "ZallDataSDK/AppPush/**/*.{h,m}"
    f.public_header_files = 'ZallDataSDK/AppPush/ZAConfigOptions+AppPush.h'
  end

  # 使用崩溃事件采集
  s.subspec 'Exception' do |e|
    e.ios.deployment_target = '8.0'
    e.dependency 'ZallDataSDK/Common'
    e.source_files  =  "ZallDataSDK/Exception/**/*.{h,m}"
    e.public_header_files = 'ZallDataSDK/Exception/ZAConfigOptions+Exception.h'
  end

  # 基于 UA，使用 UIWebView 或者 WKWebView 进行打通
  s.subspec 'WebView' do |w|
    w.ios.deployment_target = '8.0'
    w.dependency 'ZallDataSDK/Core'
    w.source_files  =  "ZallDataSDK/WebView/**/*.{h,m}"
    w.public_header_files = 'ZallDataSDK/WebView/ZallDataSDK+WebView.h'
  end

  # 基于 UA，使用 WKWebView 进行打通
  s.subspec 'WKWebView' do |w|
    w.ios.deployment_target = '8.0'
    w.dependency 'ZallDataSDK/Core'
    w.source_files  =  "ZallDataSDK/WKWebView/**/*.{h,m}"
    w.public_header_files = 'ZallDataSDK/WKWebView/ZallDataSDK+WKWebView.h'
  end

end

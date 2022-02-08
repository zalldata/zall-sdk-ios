Pod::Spec.new do |s|
  s.name         = "ZallDataSDK"
  s.version      = "0.0.3"
  s.summary      = "The official iOS SDK of zall Digital."
  s.homepage     = "https://www.zalldigital.cn"
  s.source       = { :git => 'https://github.com/zalldata/ZallDataSDK.git', :tag => "v#{s.version}" } 
  s.license = { :type => "Apache License, Version 2.0" }
  s.author = { "郭振涛" => "guozhentao@zalldigital.com" }
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Default'
  s.frameworks = 'Foundation', 'SystemConfiguration'
  s.libraries = 'icucore', 'sqlite3', 'z'

  # Base 模块
  s.subspec 'Base' do |b|
    core_dir = "ZallDataSDK/Core/**/"
    b.source_files = core_dir + "*.{h,m}"
    b.public_header_files = [
      core_dir + "ZallDataSDK.h", 
      core_dir + "ZallDataSDK+Business.h", 
      core_dir + "ZAConfigOptions.h", 
      core_dir + "ZallDataSDK+ZATrack.h", 
      core_dir + "ZAConstantsDefin.h", 
      core_dir + "ZAConstants.h",
      core_dir + "ZAConstantsEnum.h",
      core_dir + "ZASecurityPolicy.h"
    ]
    b.exclude_files = [
      core_dir + "ZAAlertViewController.{h,m}",
      core_dir + "UIView*.{h,m}",      
    ]
    b.ios.resource = 'ZallDataSDK/ZallDataSDK.bundle'
    b.ios.frameworks = 'CoreTelephony'
  end

  # Core 模块
  s.subspec 'Core' do |b|
    core_dir = "ZallDataSDK/Core/**/"
    b.source_files = core_dir + "*.{h,m}"
    b.public_header_files = [
      core_dir + "ZallDataSDK.h", 
      core_dir + "ZallDataSDK+Business.h", 
      core_dir + "ZAConfigOptions.h", 
      core_dir + "ZallDataSDK+ZATrack.h", 
      core_dir + "ZAConstantsDefin.h", 
      core_dir + "ZAConstants.h",
      core_dir + "ZAConstantsEnum.h",
      core_dir + "ZASecurityPolicy.h"
    ]
    b.ios.resource = 'ZallDataSDK/ZallDataSDK.bundle'
    b.ios.frameworks = 'CoreTelephony'
  end

  # Default 加载所有模块
  s.subspec 'Default' do |a|
    a.dependency 'ZallDataSDK/AutoTrack'
    a.dependency 'ZallDataSDK/Channel'
    a.dependency 'ZallDataSDK/Encrypt'
    a.dependency 'ZallDataSDK/DebugMode'
    a.dependency 'ZallDataSDK/RemoteConfig'
    a.dependency 'ZallDataSDK/Extension'
  end

  s.subspec 'all' do |a|
    a.dependency 'ZallDataSDK/Default'
    a.dependency 'ZallDataSDK/CAID'
    a.dependency 'ZallDataSDK/Visualized'
    a.dependency 'ZallDataSDK/Location'
    a.dependency 'ZallDataSDK/DeviceOrientation'
    a.dependency 'ZallDataSDK/AppPush'
    a.dependency 'ZallDataSDK/Exception'
    a.dependency 'ZallDataSDK/Deeplink'
  end

  # APP扩展
  s.subspec 'Extension' do |b|
    b.dependency 'ZallDataSDK/Base'
    b.source_files = "ZallDataSDKExtension/*.{h,m}"   
    b.public_header_files = [
      'ZallDataSDKExtension/ZAAppExtensionDataManager.h',
      'ZallDataSDKExtension/ZallDataSDKExtension.h',
    ]
  end

  # 全埋点
  s.subspec 'AutoTrack' do |b|
    sub_dir = "ZallDataSDK/Modules/AutoTrack/**/"
    b.dependency 'ZallDataSDK/Core'
    b.dependency 'ZallDataSDK/Extension'
    b.source_files = sub_dir + "*.{h,m}"
    b.public_header_files = [
      sub_dir + 'ZallDataSDK+ZAAutoTrack.h',
      sub_dir + 'UIView+ZAProperty.h'
    ]
    b.ios.frameworks = 'UIKit'
  end

  # 渠道匹配
  s.subspec 'Channel' do |b|
    b.dependency 'ZallDataSDK/AutoTrack'
    b.source_files = "ZallDataSDK/Modules/ChannelMatch/*.{h,m}"
    b.public_header_files = 'ZallDataSDK/Modules/ChannelMatch/ZallDataSDK+ZAChannelMatch.h'
  end

  # 支持 CAID 渠道匹配
  s.subspec 'CAID' do |f|
    f.dependency 'ZallDataSDK/Channel'
    f.source_files = "ZallDataSDK/Modules/ChannelMatch/CAID/*.{h,m}"
  end

  # JS 交互
  s.subspec 'JSBridge' do |f|
    f.dependency 'ZallDataSDK/AutoTrack'
    f.source_files = "ZallDataSDK/Modules/JSBridge/**/*.{h,m}"
    f.public_header_files = [
      'ZallDataSDK/Modules/JSBridge/ZallDataSDK+ZAJSBridge.h',
      'ZallDataSDK/Modules/JSBridge/WKWebView+ZABridge.h',
      'ZallDataSDK/Modules/JSBridge/**/ZallDataSDK+WKWebView.h'
    ]
  end

  # 可视化相关功能，包含可视化全埋点和点击图
  s.subspec 'Visualized' do |f|
    f.dependency 'ZallDataSDK/JSBridge'
    f.source_files = "ZallDataSDK/Modules/Visualized/**/*.{h,m}"
    f.public_header_files = 'ZallDataSDK/Modules/Visualized/ZallDataSDK+ZAVisualized.h'
  end

  # 开启 GPS 定位采集
  s.subspec 'Location' do |f|
    f.frameworks = 'CoreLocation'
    f.dependency 'ZallDataSDK/Core'
    f.source_files = "ZallDataSDK/Modules/Location/*.{h,m}"
    f.public_header_files = 'ZallDataSDK/Modules/Location/ZallDataSDK+ZALocation.h'
  end

  # 开启设备方向采集
  s.subspec 'DeviceOrientation' do |f|
    f.dependency 'ZallDataSDK/Core'
    f.source_files = 'ZallDataSDK/Modules/DeviceOrientation/**/*.{h,m}'
    f.public_header_files = 'ZallDataSDK/Modules/DeviceOrientation/ZallDataSDK+ZADeviceOrientation.h'
    f.frameworks = 'CoreMotion'
  end

  # 推送点击
  s.subspec 'AppPush' do |f|
    f.dependency 'ZallDataSDK/AutoTrack'
    f.source_files = "ZallDataSDK/Modules/AppPush/**/*.{h,m}"
    f.public_header_files = 'ZallDataSDK/Modules/AppPush/ZallDataSDK+ZAAppPush.h'
  end

  # 使用崩溃事件采集
  s.subspec 'Exception' do |e|
    e.dependency 'ZallDataSDK/AutoTrack'
    e.source_files  =  "ZallDataSDK/Modules/Exception/**/*.{h,m}"
    e.public_header_files = 'ZallDataSDK/Modules/Exception/ZallDataSDK+ZAException.h'
  end

  # DebugMode
  s.subspec 'DebugMode' do |e|
    e.dependency 'ZallDataSDK/AutoTrack'
    e.source_files  =  "ZallDataSDK/Modules/DebugMode/**/*.{h,m}"
    e.public_header_files = 'ZallDataSDK/Modules/DebugMode/ZallDataSDK+ZADebugMode.h'
  end

  # Deeplink
  s.subspec 'Deeplink' do |e|
    e.dependency 'ZallDataSDK/AutoTrack'
    e.source_files  =  "ZallDataSDK/Modules/Deeplink/**/*.{h,m}"
    e.public_header_files = 'ZallDataSDK/Modules/Deeplink/ZallDataSDK+ZADeeplink.h'
  end
  
  # Encrypt
  s.subspec 'Encrypt' do |e|
    e.dependency 'ZallDataSDK/AutoTrack'
    e.source_files  =  "ZallDataSDK/Modules/Encrypt/**/*.{h,m}"
    e.public_header_files = [
      'ZallDataSDK/Modules/Encrypt/ZallDataSDK+ZAEncrypt.h',
      'ZallDataSDK/Modules/Encrypt/ZAEncryptProtocol.h',
      'ZallDataSDK/Modules/Encrypt/ZASecretKey.h'
    ]
  end

  # RemoteConfig
  s.subspec 'RemoteConfig' do |e|
    e.dependency 'ZallDataSDK/Core'
    e.source_files  =  "ZallDataSDK/Modules/RemoteConfig/**/*.{h,m}"
    e.public_header_files = 'ZallDataSDK/Modules/RemoteConfig/ZallDataSDK+ZARemoteConfig.h'
  end

end

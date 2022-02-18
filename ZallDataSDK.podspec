Pod::Spec.new do |spec|
  spec.name            = "ZallDataSDK"
  spec.version         = ENV['LIB_VERSION']
  spec.summary         = "The official iOS SDK of zall Digital."
  spec.homepage        = "https://www.zalldigital.cn"
  spec.source          = { :git => 'https://github.com/zalldata/ZallDataSDK.git', :tag => "v#{spec.version}", :submodules => true }
  spec.license         = { :type => "Apache License, Version 2.0" }
  spec.author          = { "郭振涛" => "guozhentao@zalldigital.com" }
  spec.default_subspec = 'Default'
  spec.frameworks      = 'Foundation', 'SystemConfiguration'
  spec.libraries       = 'icucore', 'sqlite3', 'z'
  spec.ios.deployment_target = '8.0'

  # Core 模块
  spec.subspec 'Core' do |core|
    core_dir = "ZallDataSDK/Core/**/"
    core.source_files = core_dir + "*.{h,m}"
    core.public_header_files = [
      core_dir + "ZallDataSDK.h",
      core_dir + "ZallDataSDK+Business.h",
      core_dir + "ZAConfigOptions.h",
      core_dir + "ZallDataSDK+ZATrack.h",
      core_dir + "ZAConstantsDefin.h",
      core_dir + "ZAConstants.h",
      core_dir + "ZAConstantsEnum.h",
      core_dir + "ZASecurityPolicy.h"
    ]
    core.exclude_files = [
      core_dir + "ZAAlertViewController.{h,m}",
      core_dir + "UIView*.{h,m}",
    ]
    core.ios.resource = 'ZallDataSDK/ZallDataSDK.bundle'
    core.ios.frameworks = 'CoreTelephony'
  end

  # Core 模块
  spec.subspec 'CoreApp' do |coreapp|
    coreapp.dependency 'ZallDataSDK/Core'
    core_dir = "ZallDataSDK/Core/**/"
    coreapp.source_files = [
      core_dir + "ZAAlertViewController.{h,m}",
      core_dir + "UIView*.{h,m}",
    ]
  end

  # Default 加载模块
  spec.subspec 'Default' do |default|
    default.dependency 'ZallDataSDK/AutoTrack'
    default.dependency 'ZallDataSDK/Channel'
    default.dependency 'ZallDataSDK/Encrypt'
    default.dependency 'ZallDataSDK/Extension'
  end
  
  # All 加载所有模块
  spec.subspec 'All' do |all|
    all.dependency 'ZallDataSDK/Default'
    all.dependency 'ZallDataSDK/RemoteConfig'
    all.dependency 'ZallDataSDK/DebugMode'
    all.dependency 'ZallDataSDK/Visualized'
    all.dependency 'ZallDataSDK/Location'
    all.dependency 'ZallDataSDK/DeviceOrientation'
    all.dependency 'ZallDataSDK/AppPush'
    all.dependency 'ZallDataSDK/Exception'
    all.dependency 'ZallDataSDK/Deeplink'
  end

  # APP扩展
  spec.subspec 'Extension' do |extension|
    extension.dependency 'ZallDataSDK/Core'
    extension.source_files = "ZallDataSDKExtension/*.{h,m}"
    extension.public_header_files = [
      'ZallDataSDKExtension/ZAAppExtensionDataManager.h',
      'ZallDataSDKExtension/ZallDataSDKExtension.h',
    ]
  end

  # 全埋点
  spec.subspec 'AutoTrack' do |auto_track|
    sub_dir = "ZallDataSDK/Modules/AutoTrack/**/"
    auto_track.dependency 'ZallDataSDK/CoreApp'
    auto_track.dependency 'ZallDataSDK/Extension'
    auto_track.source_files = sub_dir + "*.{h,m}"
    auto_track.public_header_files = [
      sub_dir + 'ZallDataSDK+ZAAutoTrack.h',
      sub_dir + 'UIView+ZAProperty.h'
    ]
    auto_track.ios.frameworks = 'UIKit'
  end

  # 渠道匹配
  spec.subspec 'Channel' do |channel|
    channel.dependency 'ZallDataSDK/AutoTrack'
    channel.source_files = "ZallDataSDK/Modules/ChannelMatch/*.{h,m}"
    channel.public_header_files = 'ZallDataSDK/Modules/ChannelMatch/ZallDataSDK+ZAChannelMatch.h'
  end

  # JS 交互
  spec.subspec 'JSBridge' do |js_bridge|
    js_bridge.dependency 'ZallDataSDK/AutoTrack'
    js_bridge.source_files = "ZallDataSDK/Modules/JSBridge/**/*.{h,m}"
    js_bridge.public_header_files = [
      'ZallDataSDK/Modules/JSBridge/ZallDataSDK+ZAJSBridge.h',
      'ZallDataSDK/Modules/JSBridge/WKWebView+ZABridge.h',
      'ZallDataSDK/Modules/JSBridge/**/ZallDataSDK+WKWebView.h'
    ]
  end

  # 可视化相关功能，包含可视化全埋点和点击图
  spec.subspec 'Visualized' do |visualized|
    visualized.dependency 'ZallDataSDK/JSBridge'
    visualized.source_files = "ZallDataSDK/Modules/Visualized/**/*.{h,m}"
    visualized.public_header_files = 'ZallDataSDK/Modules/Visualized/ZallDataSDK+ZAVisualized.h'
  end

  # 开启 GPS 定位采集
  spec.subspec 'Location' do |location|
    location.frameworks = 'CoreLocation'
    location.dependency 'ZallDataSDK/CoreApp'
    location.dependency 'ZallDataSDK/Extension'
    location.source_files = "ZallDataSDK/Modules/Location/*.{h,m}"
    location.public_header_files = 'ZallDataSDK/Modules/Location/ZallDataSDK+ZALocation.h'
  end

  # 开启设备方向采集
  spec.subspec 'DeviceOrientation' do |orientation|
    orientation.dependency 'ZallDataSDK/CoreApp'
    orientation.dependency 'ZallDataSDK/Extension'

    orientation.source_files = 'ZallDataSDK/Modules/DeviceOrientation/**/*.{h,m}'
    orientation.public_header_files = 'ZallDataSDK/Modules/DeviceOrientation/ZallDataSDK+ZADeviceOrientation.h'
    orientation.frameworks = 'CoreMotion'
  end

  # 推送点击
  spec.subspec 'AppPush' do |app_push|
    app_push.dependency 'ZallDataSDK/AutoTrack'
    app_push.source_files = "ZallDataSDK/Modules/AppPush/**/*.{h,m}"
    app_push.public_header_files = 'ZallDataSDK/Modules/AppPush/ZallDataSDK+ZAAppPush.h'
  end

  # 使用崩溃事件采集
  spec.subspec 'Exception' do |exception|
    exception.dependency 'ZallDataSDK/AutoTrack'
    exception.source_files  =  "ZallDataSDK/Modules/Exception/**/*.{h,m}"
    exception.public_header_files = 'ZallDataSDK/Modules/Exception/ZallDataSDK+ZAException.h'
  end

  # DebugMode
  spec.subspec 'DebugMode' do |debug_mode|
    debug_mode.dependency 'ZallDataSDK/AutoTrack'
    debug_mode.source_files  =  "ZallDataSDK/Modules/DebugMode/**/*.{h,m}"
    debug_mode.public_header_files = 'ZallDataSDK/Modules/DebugMode/ZallDataSDK+ZADebugMode.h'
  end

  # Deeplink
  spec.subspec 'Deeplink' do |deeplink|
    deeplink.dependency 'ZallDataSDK/AutoTrack'
    deeplink.source_files  =  "ZallDataSDK/Modules/Deeplink/**/*.{h,m}"
    deeplink.public_header_files = 'ZallDataSDK/Modules/Deeplink/ZallDataSDK+ZADeeplink.h'
  end
  
  # Encrypt
  spec.subspec 'Encrypt' do |encrypt|
    encrypt.dependency 'ZallDataSDK/AutoTrack'
    encrypt.source_files  =  "ZallDataSDK/Modules/Encrypt/**/*.{h,m}"
    encrypt.public_header_files = [
      'ZallDataSDK/Modules/Encrypt/ZallDataSDK+ZAEncrypt.h',
      'ZallDataSDK/Modules/Encrypt/ZAEncryptProtocol.h',
      'ZallDataSDK/Modules/Encrypt/ZASecretKey.h'
    ]
  end

  # RemoteConfig
  spec.subspec 'RemoteConfig' do |remote_config|
    remote_config.dependency 'ZallDataSDK/AutoTrack'
    remote_config.source_files  =  "ZallDataSDK/Modules/RemoteConfig/**/*.{h,m}"
    remote_config.public_header_files = 'ZallDataSDK/Modules/RemoteConfig/ZallDataSDK+ZARemoteConfig.h'
  end

end

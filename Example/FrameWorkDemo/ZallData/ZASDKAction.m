//
//  ZASDKAction.m
//  ZallData
//
//  Created by guo on 2022/1/24.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

#import "ZASDKAction.h"
#import <ZallDataSDK/ZallDataSDK.h>


typedef void (^ActionBlock)(void);


NS_INLINE void zaprintf(id obj){
    NSLog(@"%@",obj);
}



@interface NSDictionary (category)

-(id)firstValue;

-(id)firstKey;

@end

@implementation NSDictionary (category)


-(id)firstValue{
    return self.allValues.firstObject;
}

-(id)firstKey{
    return self.allKeys.firstObject;
}

@end

@interface ZASDKAction ()
@property(nonatomic, strong) NSArray *list;
@end

@implementation ZASDKAction

+(NSArray<NSDictionary<NSString *,NSArray *>*>*)sdkDataList{
    NSArray * array = @[
        @{@"公共属性"     :[self publicAttribute]},
        @{@"loginId"    :[self loginId]},
        @{@"匿名ID"      :[self anonymousID]},
        @{@"Bind"       :[self bind]},
        @{@"Item"       :[self item]},
        @{@"UserProfile":[self userProfile]},
        @{@"TrackTimer" :[self trackTimer]},
        @{@"track event":[self trackEvent]},
        @{@"TrackView"  :[self trackView]},
        @{@"渠道"        :[self trackChannel]},
        @{@"DebugMode"  :[self debugMode]},
        @{@"Deeplink"   :[self deeplink]},
        @{@"设备方向"     :[self screenOrientation]},
        @{@"JavaScript" :[self javascript]},
        @{@"Location"   :[self location]},
        @{@"远程配置"     :[self remoteConfig]},
        @{@"可视化"      :[self visualized]},
        @{@"HeatMap"    :[self heatMap]}
    ];
    
    return array;
}
#pragma mark - 公共属性
+(NSArray*)publicAttribute{
    return @[
        @{
            @"返回预置的属性":^{
                zaprintf([ZallDataSharedSDK() getPresetProperties]);
            }
            
        },
        @{
            @"注册公共属性":^{
                NSDictionary * dict = @{@"key_first":@"value_first"};
                [ZallDataSharedSDK() registerSuperProperties:dict];
            }
        },
        @{
            @"动态公共属性":^{
                __block NSDictionary * dict = @{@"key_dy_first":@"value_dy_first"};
                [ZallDataSharedSDK() registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
                    return dict;
                }];
            }
        },
        @{
            @"注销公共属性":^{
                [ZallDataSharedSDK() unregisterSuperProperty:@"key_first"];
            }
        },
        @{
            @"清空公共属性":^{
                [ZallDataSharedSDK() clearSuperProperties];
            }
        },
        @{
            @"获取当前公共属性":^{
                zaprintf([ZallDataSharedSDK() currentSuperProperties]);
            }
        }
    ];
}

#pragma mark - loginId
+(NSArray*)loginId{
    return @[
        @{
            @"设置当前用户的 loginId":^{
                [ZallDataSharedSDK() login:@"1234567890"];
            }
            
        },
        @{
            @"获取当前用户ID":^{
                zaprintf([ZallDataSharedSDK() loginId]);
            }
        },
        @{
            @"当前用户的 loginId 并添加扩招属性":^{
                NSDictionary * dict = @{@"username":@"666"};
                [ZallDataSharedSDK() login:@"9876543210" withProperties:dict];
            }
        },
        @{
            @"注销，清空当前用户的 loginId":^{
                [ZallDataSharedSDK() logout];
            }
        },
        
    ];
}

#pragma mark - anonymousID
+(NSArray*)anonymousID{
    return @[
        @{
            @"获取用户的唯一用户标识":^{
                zaprintf([ZallDataSharedSDK() distinctId]);
            }
            
        },
        @{
            @"获取匿名 id":^{
                zaprintf([ZallDataSharedSDK() anonymousId]);
            }
        },
        @{
            @"重置默认匿名 id":^{
                [ZallDataSharedSDK() resetAnonymousId];
            }
        },
        @{
            @"指定匿名ID":^{
                [ZallDataSharedSDK() identify:@"3333"];
            }
        },
    ];
}

#pragma mark - Bind
+(NSArray*)bind{
    return @[
        
        @{
            @"绑定":^{
                [ZallDataSharedSDK() bind:@"bind_key" value:@"bind_value"];
            }
        },
        @{
            @"解绑":^{
                [ZallDataSharedSDK() unbind:@"bing_key" value:@"bind_value"];
            }
        }
    ];
}

#pragma mark - Item
+(NSArray*)item{
    return @[
        
        @{
            @"设置 item":^{
                [ZallDataSharedSDK() itemSetWithType:@"item" itemId:@"1" properties:@{@"name1": @"Item1", @"name2": @"Item2"}];
                
            }
        },
        @{
            @"删除 item":^{
                [ZallDataSharedSDK() itemDeleteWithType:@"item" itemId:@"1"];
            }
        }
    ];
}

#pragma mark - UserProfile
+(NSArray*)userProfile{
    return @[
        
        @{
            @"设置用户的一个或者几个 Profiles":^{
                [ZallDataSharedSDK() set:@{
                    @"Profiles1":@"Profiles1",
                    @"Profiles2":@{
                        @"Profiles2_1":@"Profiles2_1",
                        @"Profiles2_2":@"Profiles2_2",
                        @"Profiles2_3":@{
                            @"Profiles2_3_1":@"Profiles2_3_1",
                            @"Profiles2_3_2":@"Profiles2_3_2",
                        }
                    }
                }];
                
            }
        },
        @{
            @"设置用户的pushId":^{
                [ZallDataSharedSDK() profilePushKey:@"pushkey1" pushId:@"pushId1"];
            }
        },
        @{
            @"删除用户设置的 pushId":^{
                [ZallDataSharedSDK() profileUnsetPushKey:@"pushkey1"];
            }
        },
        @{
            @"首次设置用户Profiles":^{
                [ZallDataSharedSDK() setOnce:@{
                    @"OnceProfiles1":@"OnceProfiles1",
                    @"OnceProfiles2":@{
                        @"OnceProfiles2_1":@"OnceProfiles2_1",
                        @"OnceProfiles2_2":@"OnceProfiles2_2",
                        @"OnceProfiles2_3":@{
                            @"OnceProfiles2_3_1":@"OnceProfiles2_3_1",
                            @"OnceProfiles2_3_2":@"OnceProfiles2_3_2",
                        }
                    }
                }];
            }
        },
        @{
            @"设置用户的单个 Profile":^{
                [ZallDataSharedSDK() set:@"Profiles1" to:@{
                    @"Profiles1":@"Profiles1",
                    @"Profiles2":@{
                        @"Profiles2_1":@"Profiles2_1",
                        @"Profiles2_2":@"Profiles2_2",
                        @"Profiles2_3":@{
                            @"Profiles2_3_1":@"Profiles2_3_1",
                            @"Profiles2_3_2":@"Profiles2_3_2",
                        }
                    }
                }];
                
            }
        },
        @{
            @"首次设置用户的单个 Profile 的内容":^{
                [ZallDataSharedSDK() setOnce:@"OnceProfiles1" to:@{
                    @"OnceProfiles1":@"OnceProfiles1",
                    @"OnceProfiles2":@{
                        @"OnceProfiles2_1":@"OnceProfiles2_1",
                        @"OnceProfiles2_2":@"OnceProfiles2_2",
                        @"OnceProfiles2_3":@{
                            @"OnceProfiles2_3_1":@"OnceProfiles2_3_1",
                            @"OnceProfiles2_3_2":@"OnceProfiles2_3_2",
                        }
                    }
                }];
                
            }
        },
        @{
            @"删除某个 Profile 的全部内容":^{
                [ZallDataSharedSDK() unset:@"Profiles1"];
                
            }
        },
        @{
            @"给一个数值类型的 Profile 增加一个数值":^{
                [ZallDataSharedSDK() increment:@"increment" by:@(1)];
            }
        },
        @{
            @"给多个数值类型的 Profile 增加数值":^{
                [ZallDataSharedSDK() increment:@{
                    @"increment1":@(1),
                    @"increment2":@(1),
                }];
            }
        },
        @{
            @"向一个 NSSet 或者 NSArray 类型的 value 添加一些值":^{
                [ZallDataSharedSDK() append:@"append" by:@[@"append1",@"append2"]];
                
            }
        },
        @{
            @"删除当前这个用户的所有记录":^{
                [ZallDataSharedSDK() deleteUser];
                
            }
        },
        @{
            @"清除 keychain 缓存数据":^{
                [ZallDataSharedSDK() clearKeychainData];
                
            }
        },
        @{
            @" 获取最后设置的属性":^{
                zaprintf([ZallDataSharedSDK() getLastScreenTrackProperties]);
                
            }
        }
    ];
}

#pragma mark - TrackTimer
+(NSArray*)trackTimer{
    return @[
        @{
            @"开始事件计时":^{
                zaprintf([ZallDataSharedSDK() trackTimerStart:@"time_track01"]);
            },
        },
        @{
            @"暂停事件计时":^{
                [ZallDataSharedSDK() trackTimerPause:@"time_track01"];
            },
        },
        @{
            @"恢复事件计时":^{
                [ZallDataSharedSDK() trackTimerResume:@"time_track01"];
            },
        },
        @{
            @"结束事件计时有参":^{
                [ZallDataSharedSDK() trackTimerEnd:@"time_track01" withProperties:@{
                    @"time_end":@"time_end"
                }];
            },
        },
        @{
            @"结束事件计时":^{
                [ZallDataSharedSDK() trackTimerEnd:@"time_track01"];
            },
        },
        @{
            @"删除事件计时":^{
                [ZallDataSharedSDK() trackRemoveTimer:@"time_track01"];
            },
        },
        @{
            @"清除所有事件计时器":^{
                [ZallDataSharedSDK() clearTrackTimer];
            },
        },
    ];
}

#pragma mark - track event
+(NSArray*)trackEvent{
    return @[
        @{
            @"Track App Extension groupIdentifier 中缓存的数据":^{
                [ZallDataSharedSDK() trackEventFromExtensionWithGroupIdentifier:@"34" completion:^(NSString * _Nonnull groupIdentifier, NSArray * _Nonnull events) {
                    zaprintf(events);
                }];
            },
        },
        @{
            @"修改入库之前的事件属性":^{
                [ZallDataSharedSDK() trackEventWillSave:^BOOL(NSString * _Nonnull eventName, NSMutableDictionary<NSString *,id> * _Nonnull properties) {
                    zaprintf(properties);
                    return YES;
                }];
            },
        },
        @{
            @"调用 track":^{
                [ZallDataSharedSDK() track:@"event_01"];
            },
        },
        @{
            @"调用 track 有属性":^{
                [ZallDataSharedSDK() track:@"event_01" withProperties:@{
                    @"time_end":@"time_end"
                }];
            },
        },
        @{
            @"强制上传埋点事件":^{
                [ZallDataSharedSDK() trackForceSendAll];
            },
        },
        @{
            @"删除本地所有缓存事件":^{
                [ZallDataSharedSDK() trackDeleteAll];
            },
        }
    ];
}

#pragma mark - TrackView
+(NSArray*)trackView{
    return @[
        @{
            @"是否开启 AutoTrack":^{
                zaprintf(@([ZallDataSharedSDK() isAutoTrackEnabled]));
            },
        },
        @{
            @"通过代码触发 UIView 的 $AppClick 事件":^{
                [ZallDataSharedSDK() trackViewAppClick:rootViewController().view];
            },
        },
        @{
            @"通过代码触发  $AppViewScreen":^{
                [ZallDataSharedSDK() trackViewScreen:rootViewController()];
            },
        },
        @{
            @"通过代码触发  $AppViewScreen properties":^{
                [ZallDataSharedSDK() trackViewScreen:rootViewController() properties:@{
                    @"properties":@"properties"
                }];
            },
        },
        @{
            @"通过代码触发  $AppViewScreen 通过url":^{
                [ZallDataSharedSDK() trackViewScreen:@"url" withProperties:@{@"properties":@"properties"}];
            },
        }
    ];
}

#pragma mark - track Channel
+(NSArray*)trackChannel{
    return @[
        @{
            @"track 渠道":^{
                [ZallDataSharedSDK() trackChannelEvent:@"channel1"];
            },
        },
        @{
            @"track 渠道 加参":^{
                [ZallDataSharedSDK() trackChannelEvent:@"channel2" properties:@{
                    @"channel2_properties":@"channel2_properties"
                }];
            },
        },
        @{
            @" App 首次启动时追踪渠道来源":^{

                [ZallDataSharedSDK() trackAppInstall];
            },
        },
        @{
            @"App 首次启动时追踪渠道来源 填入事件属性 $utm_ 开头的一系列属性中":^{
                [ZallDataSharedSDK() trackAppInstallWithProperties:@{
                    @"properties":@"properties"
                }];
            },
        },
        @{
            @"App 首次启动时追踪渠道来源 ":^{
                [ZallDataSharedSDK() trackAppInstallWithProperties:@{
                    @"properties":@"properties"
                } disableCallback:YES];
            },
        },
        @{
            @"App 首次启动时追踪渠道来源 自定义事件":^{
                [ZallDataSharedSDK() trackInstallation:@"aaa"];
            },
        },
        @{
            @"App 首次启动时追踪渠道来源 自定义事件 自定义属性":^{
                [ZallDataSharedSDK() trackInstallation:@"aaa" withProperties:@{
                    @"properties":@"properties"
                }];
            },
        },
        @{
            @"App 首次启动时追踪渠道来源 自定义事件 自定义属性":^{
                [ZallDataSharedSDK() trackInstallation:@"aaa" withProperties:@{
                    @"properties":@"properties"
                } disableCallback:YES];
            },
        }
    ];
}

#pragma mark - DebugMode
+(NSArray*)debugMode{
    return @[
        @{
            @"设置是否显示 debugInfoView":^{
                [ZallDataSharedSDK() showDebugInfoView:YES];

            }
        }
    ];
}

#pragma mark - Deeplink
+(NSArray*)deeplink{
    return @[
        @{
            @"DeepLink 回调函数":^{
                [ZallDataSharedSDK() setDeeplinkCallback:^(NSString * _Nullable params, BOOL success, NSInteger appAwakePassedTime) {
                    zaprintf(params);
                    zaprintf(@(appAwakePassedTime));
                }];
            }
        },
        @{
            @"触发 $AppDeepLinkLaunch 事件":^{
                [ZallDataSharedSDK() trackDeepLinkLaunchWithURL:@"AppDeepLinkLaunch666"];
            }
        }
    ];
}

#pragma mark - ScreenOrientation
+(NSArray*)screenOrientation{
    return @[
        @{
            @"设备方向 开关":^{
                [ZallDataSharedSDK() enableTrackScreenOrientation:YES];
            }
        }
    ];
}

#pragma mark - JS
+(NSArray*)javascript{
    return @[
        @{
            @"WKWebView":^{
                [[self findCurrentShowingViewController].navigationController pushViewController:[NSClassFromString(@"ZAWebViewController") new] animated:YES];

            }
        },
        @{
            @"H5 数据打通的时候默认通过 ServerUrl 校验":^{
                [ZallDataSharedSDK() addWebViewUserAgentZallDataFlag];
            }
        },
        @{
            @"H5 数据打通的时候是否校验":^{
                [ZallDataSharedSDK() addWebViewUserAgentZallDataFlag:YES];
            }
        },
        @{
            @"H5 数据打通的时候是否校验":^{
                [ZallDataSharedSDK() addWebViewUserAgentZallDataFlag:YES userAgent:@""];
            }
        },
        @{
            @"将 distinctId 传递给当前的 WebView":^{

                [ZallDataSharedSDK() showUpWebView:nil WithRequest:nil];
            }
        },
        @{
            @"将 distinctId 传递给当前的 WebView 验证":^{

                [ZallDataSharedSDK() showUpWebView:nil WithRequest:nil enableVerify:YES];
            }
        },
        @{
            @"将 distinctId 传递给当前的 WebView 扩展属性":^{

                [ZallDataSharedSDK() showUpWebView:nil WithRequest:nil andProperties:@{}];
            }
        },
        @{
            @"桥接h5事件上传":^{

                [ZallDataSharedSDK() trackFromH5WithEvent:@"trackFromH5WithEvent"];
            }
        },
        @{
            @"桥接h5事件上传 验证":^{

                [ZallDataSharedSDK() trackFromH5WithEvent:@"trackFromH5WithEvent" enableVerify:YES];
            }
        },

    ];
}

#pragma mark - Location
+(NSArray*)location{
    return @[
        @{@"位置信息采集开关":^{
            [ZallDataSharedSDK() enableTrackGPSLocation:YES];
        }}
    ];
}

#pragma mark - RemoteConfig
+(NSArray*)remoteConfig{
    return @[
        @{@"请求远程配置":^{
            [ZallDataSDK updateServerUrl:@"url" isRequestRemoteConfig:NO];
        }},
        @{@"发起远程配置":^{
            [ZallDataSDK updateRemoteConfigServerRequest];
        }}
    ];
}

#pragma mark - 可视化
+(NSArray*)visualized{
    return @[
        @{@"是否开启":^{
            [ZallDataSharedSDK() isVisualizedAutoTrackEnabled];
        }},
        @{@"指定哪些页面开启 可视化全埋点 分析":^{
            [ZallDataSharedSDK() addVisualizedAutoTrackViewControllers:@[NSStringFromClass(rootViewController().class)]];
        }},
        @{@"某个页面是否开启 可视化全埋点 分析":^{
            zaprintf(@([ZallDataSharedSDK() isVisualizedAutoTrackViewController:rootViewController()]));
        }}
    ];
}
#pragma mark - HeatMap
+(NSArray*)heatMap{
    return @[
        @{@"是否开启":^{
            zaprintf(@([ZallDataSharedSDK() isHeatMapEnabled]));
        }},
        @{@"指定哪些页面开启 HeatMap 分析":^{
            [ZallDataSharedSDK() addHeatMapViewControllers:@[NSStringFromClass(rootViewController().class)]];
        }},
        @{@"某个页面是否开启 点击图 分析":^{
            zaprintf(@([ZallDataSharedSDK() isHeatMapViewController:rootViewController()]));
        }}
    ];
}
 
+(instancetype)sdkActionWithDataList:(NSArray *_Nullable)array{
    ZASDKAction * action = [[ZASDKAction alloc] init];
    action.list = array?array:@[];
    return action;
}
-(NSArray *)list{
    if (!_list) {
        _list = [ZASDKAction sdkDataList];
    }
    return _list;
}
 
-(NSInteger)count{
    return self.list.count;
}
-(NSString *)cellForWithRow:(NSInteger)row{
    NSDictionary * dict = self.list[row];
    return dict.firstKey;
}
-(void)cellForSelecttWithRow:(NSInteger)row withBlcok:(void(^)(ZASDKAction *action))block{
    NSDictionary * dict = self.list[row];
    if ([dict.firstValue isKindOfClass:NSArray.class]) {
        if (block) {
            block([ZASDKAction sdkActionWithDataList:dict.firstValue]);
        }
    }else{
        ActionBlock action = dict.firstValue;
        if (action) {
           action();
        }
    }
}
+ (UIViewController *)findCurrentShowingViewController {
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

//注意考虑几种特殊情况：①A present B, B present C，参数vc为A时候的情况
/* 完整的描述请参见文件头部 */
+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    //方法1：递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) { //注要优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }
    
    return currentShowingVC;
    
    /*
    //方法2：遍历方法
    while (1)
    {
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
            
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
            
        } else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
            
        //} else if (vc.childViewControllers.count > 0) {
        //    //如果是普通控制器，找childViewControllers最后一个
        //    vc = [vc.childViewControllers lastObject];
        } else {
            break;
        }
    }
    return vc;
    //*/
}

@end

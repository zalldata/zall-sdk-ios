//
// ZAAppPushConstants.h
// ZallDataSDK
//
// Created by guo on 2021/1/18.
// Copyright © 2021 Zall Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

//AppPush Notification related
extern NSString * const kZAEventNameNotificationClick;
extern NSString * const kZAEventPropertyNotificationTitle;
extern NSString * const kZAEventPropertyNotificationContent;
extern NSString * const kZAEventPropertyNotificationServiceName;
extern NSString * const kZAEventPropertyNotificationChannel;
extern NSString * const kZAEventPropertyNotificationServiceNameLocal;
extern NSString * const kZAEventPropertyNotificationServiceNameJPUSH;
extern NSString * const kZAEventPropertyNotificationServiceNameGeTui;
extern NSString * const kZAEventPropertyNotificationChannelApple;

//identifier for third part push service
extern NSString * const kZAPushServiceKeyJPUSH;
extern NSString * const kZAPushServiceKeyGeTui;
extern NSString * const kZAPushServiceKeySF;

//APNS related key
extern NSString * const kZAPushAppleUserInfoKeyAps;
extern NSString * const kZAPushAppleUserInfoKeyAlert;
extern NSString * const kZAPushAppleUserInfoKeyTitle;
extern NSString * const kZAPushAppleUserInfoKeyBody;

//sf_data related properties
extern NSString * const kSFMessageTitle;
extern NSString * const kSFPlanStrategyID;
extern NSString * const kSFChannelCategory;
extern NSString * const kSFAudienceID;
extern NSString * const kSFChannelID;
extern NSString * const kSFLinkUrl;
extern NSString * const kSFPlanType;
extern NSString * const kSFChannelServiceName;
extern NSString * const kSFMessageID;
extern NSString * const kSFPlanID;
extern NSString * const kSFStrategyUnitID;
extern NSString * const kSFEnterPlanTime;
extern NSString * const kSFMessageContent;

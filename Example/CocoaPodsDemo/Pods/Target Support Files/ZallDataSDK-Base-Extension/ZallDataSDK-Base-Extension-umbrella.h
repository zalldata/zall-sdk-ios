#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ZallDataSDK.h"
#import "ZallDataSDK+Business.h"
#import "ZAConfigOptions.h"
#import "ZallDataSDK+ZATrack.h"
#import "ZAConstantsDefin.h"
#import "ZAConstantsEnum.h"
#import "ZASecurityPolicy.h"
#import "ZAAppExtensionDataManager.h"
#import "ZallDataSDKExtension.h"

FOUNDATION_EXPORT double ZallDataSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char ZallDataSDKVersionString[];


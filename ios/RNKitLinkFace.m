//
//  RNKitLinkFace.m
//  RNKitLinkFace
//
//  Created by SimMan on 2017/8/29.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import "RNKitLinkFace.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#else
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"
#import "RCTRootView.h"
#endif

#import "RNKitLinkFaceUtils.h"
#import "STMultipleLivenessController.h"
#import "STImage.h"
#import "STAlertView.h"

@interface RNKitLinkFace() <STMultipleLivenessDelegate, STAlertViewDelegate>

@property (nonatomic , retain) STMultipleLivenessController *multipleLiveVC;

@end

@implementation RNKitLinkFace {
    BOOL _hasListener;
    RCTPromiseResolveBlock _resolve;
    RCTPromiseRejectBlock _reject;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"STMultiLivenessDidStart"];
}

RCT_EXPORT_METHOD(start:(NSDictionary *)args
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    _resolve = resolve;
    _reject = reject;

    [self clean];
    
    UIViewController *presentingController = RCTPresentedViewController();
   
    if (presentingController == nil) {
        RCTLogError(@"Tried to display action sheet picker view but there is no application window.");
        return;
    }
    
    if (!args) {
        reject(@"ArgsNull", @"参数不能为空", nil);
    }
    
    NSString *argsJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:args options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    BOOL bJsonOK = [self.multipleLiveVC setJsonCommand:argsJson];
    
    if (!bJsonOK) {
        reject(@"BadJson", @"解析Json指令失败!", nil);
    } else {
        if (args[@"voicePromptOn"]) {
            BOOL voicePromptOn = [RCTConvert BOOL:args[@"voicePromptOn"]];
            [self.multipleLiveVC setVoicePromptOn:voicePromptOn];
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.multipleLiveVC];
        [navigationController setNavigationBarHidden:NO];
        [navigationController.navigationBar setValue:@0 forKeyPath:@"backgroundView.alpha"];
        [presentingController presentViewController:navigationController animated:YES completion:^{
            [_multipleLiveVC restart];
        }];
    }
}

RCT_EXPORT_METHOD(version:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve([NSString stringWithFormat:@"%@", [self.multipleLiveVC getLivenessVersion]]);
}

RCT_EXPORT_METHOD(clean) {
    [RNKitLinkFaceUtils cleanLinkFacePath];
}

#pragma - mark -
#pragma - mark STMultipleLivenessDelegate
- (void)STMultiLivenessDidStart
{
    if (_hasListener) {
        [self sendEventWithName:@"STMultiLivenessDidStart" body:nil];
    }
}

- (void)STMultiLivenessDidSuccessfulGetData:(NSData *)encryTarData
                                   stImages:(NSArray *)arrSTImage
{
    NSMutableDictionary *resDic = [NSMutableDictionary new];
    
    if (encryTarData) {
        NSString *encryTarDataPath = [RNKitLinkFaceUtils saveFaceData:encryTarData];
        [resDic setObject:encryTarDataPath ? : [NSNull null] forKey:@"encryTarData"];
    }
    
    if (arrSTImage) {
        NSMutableArray *imgArr = [NSMutableArray arrayWithCapacity:arrSTImage.count];
        for (STImage *stImage in arrSTImage) {
            NSString *imgPath = [RNKitLinkFaceUtils saveFaceImage:stImage.image];
            [imgArr addObject:imgPath ? : [NSNull null]];
        }
        [resDic setObject:imgArr forKey:@"arrSTImage"];
    }
    
    if (_resolve) {
        _resolve(resDic);
    }
    [self dismiss];
}

- (void)STMultiLivenessDidFailWithType:(STMultipleLivenessError)iErrorType
                         DetectionType:(STDetectionType)iDetectionType
                        DetectionIndex:(NSInteger)iIndex
                                  Data:(NSData *)encryTarData
{
    if (iErrorType == STMultipleLivenessFaceChanged && iIndex == 0) {
        [self.multipleLiveVC restart];
        return;
    }
    
    if (_reject) {
        switch (iErrorType) {
                
            case STMultipleLivenessInitFaild:
            {
                _reject(@"InitFaild", @"初始化失败", nil);
            }
                break;
                
            case STMultipleLivenessCameraError:
            {
                _reject(@"CameraError", @"相机权限获取失败", nil);
            }
                break;
                
            case STMultipleLivenessFaceChanged:
            {
                STAlertView *alert = [[STAlertView alloc] initWithTitle:@"采集失败" delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
                _reject(@"FaceChanged", @"人脸变更", nil);
                return;
            }
                break;
                
            case STMultipleLivenessTimeOut:
            {
                STAlertView *alert = [[STAlertView alloc] initWithTitle:@"采集失败" delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
                _reject(@"TimeOut", @"超时", nil);
                return;
            }
                break;
                
            case STMultipleLivenessWillResignActive:
            {
                _reject(@"WillResignActive", @"活体验证失败, 请保持前台运行", nil);
            }
                break;
                
                
            case STMultipleLivenessInternalError:
            {
                _reject(@"InternalError", @"内部错误", nil);
            }
                break;
                
            case STMultipleLivenessBadJson:
            {
                _reject(@"BadJson", @"解析Json指令失败!", nil);
                return;
            }
                break;
                
            default:
                _reject(@"Unknown", @"未知错误!", nil);
                break;
        }
    }
    
    [self dismiss];
}

- (void)STMultiLivenessDidCancel
{
    [self dismiss];
    if (_reject) {
        _reject(@"Cancel", @"用户取消识别", nil);
    }
}

- (void) dismiss {
    UIViewController *presentingController = RCTPresentedViewController();
    [presentingController dismissViewControllerAnimated:YES completion:nil];
}

- (void)startObserving
{
    _hasListener = YES;
}
- (void)stopObserving
{
    _hasListener = NO;
}

- (STMultipleLivenessController *)multipleLiveVC
{
    if (!_multipleLiveVC) {
        _multipleLiveVC = [[STMultipleLivenessController alloc] init];
        _multipleLiveVC.delegate = self;
    }
    return _multipleLiveVC;
}

- (void)STAlertView:(STAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self.multipleLiveVC cancel];
        }
            break;
        case 1:
        {
            [self.multipleLiveVC restart];
        }
            break;
            
        default:
        {
            [self.multipleLiveVC cancel];
        }
            break;
    }
}

@end

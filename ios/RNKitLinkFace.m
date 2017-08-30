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
#import "LFMultipleLivenessController.h"
#import "LFImage.h"
#import "STAlertView.h"

NSString *const MultiLivenessDidStart = @"MultiLivenessDidStart";
NSString *const MultiLivenessDidFail = @"MultiLivenessDidFail";

@interface RNKitLinkFace() <LFMultipleLivenessDelegate, STAlertViewDelegate>

@property (nonatomic , retain) LFMultipleLivenessController *multipleLiveVC;

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
    return @[MultiLivenessDidStart, MultiLivenessDidFail];
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
        [navigationController setNavigationBarHidden:YES];
//        [navigationController.navigationBar setValue:@0 forKeyPath:@"backgroundView.alpha"];
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
- (void)multiLivenessDidStart
{
    if (_hasListener) {
        [self sendEventWithName:@"MultiLivenessDidStart" body:nil];
    }
}

- (void) multiLivenessDidSuccessfulGetData:(NSData *)encryTarData
                                  lfImages:(NSArray *)arrLFImage
                               lfVideoData:(NSData *)lfVideoData
{
    NSMutableDictionary *resDic = [NSMutableDictionary new];
    
    if (encryTarData) {
        NSString *encryTarDataPath = [RNKitLinkFaceUtils saveFaceData:encryTarData];
        [resDic setObject:encryTarDataPath ? : [NSNull null] forKey:@"encryTarData"];
    }
    
    if (arrLFImage) {
        NSMutableArray *imgArr = [NSMutableArray arrayWithCapacity:arrLFImage.count];
        for (LFImage *stImage in arrLFImage) {
            NSString *imgPath = [RNKitLinkFaceUtils saveFaceImage:stImage.image];
            [imgArr addObject:imgPath ? : [NSNull null]];
        }
        [resDic setObject:imgArr forKey:@"arrLFImage"];
    }
    
    if (lfVideoData) {
        NSString *videoPath = [RNKitLinkFaceUtils saveFaceVideo:lfVideoData];
        [resDic setObject:videoPath ? : [NSNull null] forKey:@"lfVideoData"];
    }
    
    if (_resolve) {
        _resolve(resDic);
        _resolve = nil;
    }
    [self dismiss];
}

- (void) multiLivenessDidFailWithType:(LFMultipleLivenessError)iErrorType
                        DetectionType:(LFDetectionType)iDetectionType
                       DetectionIndex:(NSInteger)iIndex
                                 Data:(NSData *)encryTarData
                             lfImages:(NSArray *)arrLFImage
                          lfVideoData:(NSData *)lfVideoData
{
    if (iErrorType == LFMultipleLivenessFaceChanged && iIndex == 0) {
        [self.multipleLiveVC restart];
        return;
    }
    
    if (_reject) {
        switch (iErrorType) {
                
            case LFMultipleLivenessInitFaild:
            {
                [self faild:@"InitFaild" message:@"初始化失败" error:nil];
            }
                break;
                
            case LFMultipleLivenessCameraError:
            {
                [self faild:@"CameraError" message:@"相机权限获取失败" error:nil];
            }
                break;
                
            case LFMultipleLivenessFaceChanged:
            {
                STAlertView *alert = [[STAlertView alloc] initWithTitle:@"采集失败" delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
                [self faild:@"FaceChanged" message:@"人脸变更" error:nil];
                return;
            }
                break;
                
            case LFMultipleLivenessTimeOut:
            {
                STAlertView *alert = [[STAlertView alloc] initWithTitle:@"采集失败" delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
                [self faild:@"TimeOut" message:@"超时" error:nil];
                return;
            }
                break;
                
            case LFMultipleLivenessWillResignActive:
            {
                [self faild:@"WillResignActive" message:@"活体验证失败, 请保持前台运行" error:nil];
            }
                break;
                
                
            case LFMultipleLivenessInternalError:
            {
                [self faild:@"InternalError" message:@"内部错误" error:nil];
            }
                break;
                
            case LFMultipleLivenessBadJson:
            {
                [self faild:@"BadJson" message:@"解析Json指令失败!" error:nil];
                return;
            }
                break;
                
            default:
                [self faild:@"Unknown" message:@"未知错误!" error:nil];
                break;
        }
    }
    
    [self dismiss];
}

- (void) multiLivenessDidCancel
{
    [self faild:@"Cancel" message:@"用户取消识别" error:nil];
}

- (void) faild:(NSString *)code message:(NSString *)message error:(NSError *)error
{
    if (_reject) {
        _reject(code, message, error);
        _reject = nil;
    }
    if (_hasListener) {
        [self sendEventWithName:MultiLivenessDidFail body:nil];
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

- (LFMultipleLivenessController *)multipleLiveVC
{
    if (!_multipleLiveVC) {
        _multipleLiveVC = [[LFMultipleLivenessController alloc] init];
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
            [self dismiss];
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
            [self dismiss];
        }
            break;
    }
}

@end

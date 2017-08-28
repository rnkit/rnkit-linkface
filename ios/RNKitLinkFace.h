//
//  RNKitLinkFace.h
//  RNKitLinkFace
//
//  Created by SimMan on 2017/8/29.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#endif

@interface RNKitLinkFace : RCTEventEmitter <RCTBridgeModule>

@end

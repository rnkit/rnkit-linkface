//
//  RNKitLinkFaceUtils.h
//  RNKitLinkFace
//
//  Created by SimMan on 28/08/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RNKitLinkFaceUtils : NSObject

+ (NSString *)saveFaceImage:(UIImage *)image;
+ (NSString *)saveFaceData:(NSData *)faceData;
+ (NSString *)saveFaceVideo:(NSData *)faceVideo;

+ (BOOL)cleanLinkFacePath;

@end

//
//  RNKitLinkFaceUtils.m
//  RNKitLinkFace
//
//  Created by SimMan on 28/08/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNKitLinkFaceUtils.h"

@implementation RNKitLinkFaceUtils

+ (NSString *)saveFaceImage:(UIImage *)image
{
    if ([RNKitLinkFaceUtils createLinkFaceFolder] && image) {
        NSString *imgPath = [[RNKitLinkFaceUtils getLinkFacePath] stringByAppendingString:[NSString stringWithFormat:@"%ld.png", time(NULL)]];
        NSData *imgData = UIImageJPEGRepresentation(image, 1);
        [imgData writeToFile:imgPath atomically:YES];
        return imgPath;
    }
    return nil;
}

+ (NSString *)saveFaceData:(NSData *)faceData
{
    if ([RNKitLinkFaceUtils createLinkFaceFolder] && faceData) {
        NSString *encryTarDataPath = [[RNKitLinkFaceUtils getLinkFacePath] stringByAppendingString:[NSString stringWithFormat:@"%ld.data", time(NULL)]];
        [faceData writeToFile:encryTarDataPath atomically:YES];
        return encryTarDataPath;
    }
    return nil;
}

+ (BOOL) createLinkFaceFolder
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[RNKitLinkFaceUtils getLinkFacePath]]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:[RNKitLinkFaceUtils getLinkFacePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

+ (NSString *) getLinkFacePath
{
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *linkFacePath = [cachesDir stringByAppendingString:@"cachesDir"];
    return linkFacePath;
}

+ (BOOL)cleanLinkFacePath {
    return [[NSFileManager defaultManager] removeItemAtPath:[RNKitLinkFaceUtils getLinkFacePath] error:nil];
}

@end

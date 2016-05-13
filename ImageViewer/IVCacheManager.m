//
//  IVCacheManager.m
//  ImageViewer
//
//  Created by Khaino on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVCacheManager.h"

@implementation IVCacheManager

+ (instancetype)defaultManager {
    
    static IVCacheManager *cacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheManager = [[IVCacheManager alloc] init];
    });
    return cacheManager;
}

- (void)cacheImageWithTractId:(NSString*)trackId
                    imageType:(ImageType)imageType
                      tempLoc:(NSURL*)tempUrl
                   completion:(myCompletion)completionHandler
{

    NSURL *cacheUrl = [self imageDirForTrackId:trackId imageType:k60];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check if image already exists in image cache
    if ([fm fileExistsAtPath:[cacheUrl path]]) {
        NSLog(@"Image already exist for file : %@", cacheUrl);
        return;
    }
    
    [self createDirForTrackId:trackId];
    
    // Move image file from temp directory to image cache directory
    if ([fm fileExistsAtPath:[tempUrl path]]) {
        NSError *error = nil;
        [fm moveItemAtURL:tempUrl toURL:cacheUrl error:&error];
        
        if (error) {
            NSLog(@"File move error : %@", error);
        } else {
            completionHandler(cacheUrl);
        }
    }
}

- (BOOL)isImageCached:(NSString*)trackId
       imageType:(ImageType)imageType
{
    BOOL ret = NO;
    
    // Check if image exist in cache
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *imageDir = [self imageDirForTrackId:trackId imageType:imageType];
    if ([fm fileExistsAtPath:[imageDir path]]) {
        ret = YES;
    }
    
    return ret;
}

- (NSURL *)createDirForTrackId:(NSString *)trackId{
    
    NSURL *url = [[self cacheBaseDir] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", trackId]];
    
    NSFileManager *fm = [NSFileManager defaultManager];    
    if (![fm fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Unable to create image directory. %@, %@", error, error.userInfo);
        }
    }
    return url;
}

- (NSURL*)imageDirForTrackId:(NSString*)trackId
       imageType:(ImageType)imageType {
    
    // Get image url
    NSURL *trackUrl = [[self cacheBaseDir] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", trackId]];
    NSURL *imageUrl = [trackUrl URLByAppendingPathComponent:[self imageNameForType:imageType]];
    
    return imageUrl;
}

- (NSString*)imageNameForType:(ImageType)imageType {
    
    // Get image name depends on image type
    if (imageType == k60 ) {
        return @"60x60bb.jpg";
    } else {
        return @"600x600bb.jpg";
    }
}

- (NSURL*)cacheBaseDir {
    
    // Get cache base directory
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    // Get image cache directory
    NSURL *url = [documents URLByAppendingPathComponent:@"image"];
    
    return url;
}

@end

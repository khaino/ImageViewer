//
//  IVCacheManager.m
//  ImageViewer
//
//  Created by Khaino on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVCacheManager.h"
#import "ImageInfoManager.h"
#import "ImageInfo.h"

@interface IVCacheManager()

/** Is cache cleaning is in progress */
@property(nonatomic) BOOL cleanProgress;

@end

@implementation IVCacheManager


+ (instancetype)defaultManager {
    
    static IVCacheManager *cacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheManager.cleanProgress = NO;
        cacheManager = [[IVCacheManager alloc] init];
    });
    return cacheManager;
}

- (void)cacheImageWithTractId:(NSString*)trackId
                    imageType:(ImageType)imageType
                      tempLoc:(NSURL*)tempUrl
                   completion:(myCompletion)completionHandler
{

    
    
    NSURL *cacheUrl = [self imageDirForTrackId:trackId imageType:imageType];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check if image already exists in image cache
    if ([fm fileExistsAtPath:[cacheUrl path]]) {
        DDLogDebug(@"Image already exist for file : %@", cacheUrl);
        return;
    }
    
    [self createDirForTrackId:trackId];
    
    // Move image file from temp directory to image cache directory
    if ([fm fileExistsAtPath:[tempUrl path]]) {
        NSError *error = nil;
        [fm moveItemAtURL:tempUrl toURL:cacheUrl error:&error];
        
        if (error) {
            DDLogError(@"File move error : %@", error);
        } else {
            completionHandler(cacheUrl);
        }
    }
    
    [self cleanImageCache];
    
    
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

- (NSURL*)imageDirForTrackId:(NSString*)trackId
       imageType:(ImageType)imageType {
    
    // Get image url
    NSURL *trackUrl = [[self cacheBaseDir] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", trackId]];
    NSURL *imageUrl = [trackUrl URLByAppendingPathComponent:[self imageNameForType:imageType]];
    
    return imageUrl;
}

- (void)cleanImageCache {
    
    if (self.cleanProgress) return;
    self.cleanProgress = YES;
    
    int thumpnailMax = 150;
    int normalMax = 75;
    
    NSArray *k60ImgArr = [[ImageInfoManager defaultManager] getAllImageInfoWithType:k60];
    if (k60ImgArr.count > thumpnailMax) {
        DDLogDebug(@"Clean Cache For Thumpnail");
    
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastAccess" ascending:YES];
        k60ImgArr = [k60ImgArr sortedArrayUsingDescriptors:@[descriptor]];
        NSArray *toDelete = [k60ImgArr subarrayWithRange:NSMakeRange(0, k60ImgArr.count - thumpnailMax)];
        
        for (ImageInfo *imageInfo in toDelete) {
            if ([self deleteImageCachedForTrackId:imageInfo.trackId imageType:k60]) {
                [[ImageInfoManager defaultManager]deleteImageInfo:imageInfo.imageId];
            }
        }
    }
    
    NSArray *k600ImgArr = [[ImageInfoManager defaultManager] getAllImageInfoWithType:k600];
    
    if (k600ImgArr.count > normalMax) {
        DDLogDebug(@"Clean Cache For Normal Image");
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastAccess" ascending:YES];
        k600ImgArr = [k600ImgArr sortedArrayUsingDescriptors:@[descriptor]];
        NSArray *toDelete = [k600ImgArr subarrayWithRange:NSMakeRange(0, k600ImgArr.count - normalMax)];
        
        for (ImageInfo *imageInfo in toDelete) {
            if ([self deleteImageCachedForTrackId:imageInfo.trackId imageType:k600]) {
                [[ImageInfoManager defaultManager]deleteImageInfo:imageInfo.imageId];
            }
        }
    }
    self.cleanProgress = NO;
}



- (BOOL)deleteImageCachedForTrackId:(NSString*)trackId imageType:(ImageType)imageType {
    
    BOOL ret = NO;
    NSURL *imgUrl = [self imageDirForTrackId:trackId imageType:imageType];
    NSString *imgPath =[imgUrl path];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:imgPath]) {
        NSError *error;
        [fm removeItemAtPath:[imgUrl path] error:&error];
        if (error) {
            DDLogError(@"Error in cache deletion trackId : %@", trackId);
        } else {
            DDLogDebug(@"Remove from cache image  id: %@ type: %ld", trackId, (long)imageType);
            ret = YES;
        }
    }
    return ret;
}

/*
 * @brief Create dir in cache for given track.
 * @param trackId Podcast image track id.
 * @return Return url of newly created dir for given track id.
 */
- (NSURL *)createDirForTrackId:(NSString *)trackId{
    
    NSURL *url = [[self cacheBaseDir] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", trackId]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            DDLogError(@"Unable to create image directory. %@, %@", error, error.userInfo);
        }
    }
    return url;
}

/*
 * @brief Get image name for given image type.
 * @param imageType image type.
 * @return Return image name.
 */
- (NSString*)imageNameForType:(ImageType)imageType {
    
    // Get image name depends on image type
    if (imageType == k60 ) {
        return @"60x60bb.jpg";
    } else {
        return @"600x600bb.jpg";
    }
}

/*
 * @brief Get base dir for image cache.
 * @return url for base dir.
 */
- (NSURL*)cacheBaseDir {
    
    // Get cache base directory
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    // Get image cache directory
    NSURL *url = [documents URLByAppendingPathComponent:@"image"];
    
    return url;
}

@end

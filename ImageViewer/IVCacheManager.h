//
//  IVCacheManager.h
//  ImageViewer
//
//  Created by Khaino on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumType.h"

/** This class is to cache image */
@interface IVCacheManager : NSObject



/** @brief Completion handler type for cache completion */
typedef void(^myCompletion)(NSURL*);

/*
 * @brief Retrun IVCacheManager singleton instance.
 * @return IVCacheManager instance.
 */
+ (instancetype)defaultManager;

/*
 * @brief Check if the given image is cached.
 * @param trackId Podcast image track id.
 * @param imageType image type.
 * @return Return YES if image is cached, NO otherwise.
 */
- (BOOL)isImageCached:(NSString*)trackId imageType:(ImageType)imageType;

/*
 * @brief Cache a given image.
 * @param trackId Podcast image track id.
 * @param imageType image type.
 * @param tempUrl image temp url.
 * @param completionHandler completion handler.
 * @return none.
 */
- (void)cacheImageWithTractId:(NSString*)trackId imageType:(ImageType)imageType tempLoc:(NSURL*)tempUrl completion:(myCompletion)completionHandler;

/*
 * @brief Crate image directory in cache for given trackId.
 * @param trackId Podcast image track id.
 * @param imageType image type.
 * @return none.
 */
- (NSURL*)imageDirForTrackId:(NSString*)trackId imageType:(ImageType)imageType;

@end

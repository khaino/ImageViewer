//
//  IVCacheManager.h
//  ImageViewer
//
//  Created by Khaino on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    k60,
    k600
} ImageType;

typedef void(^myCompletion)(NSURL*);

@interface IVCacheManager : NSObject

+ (instancetype)defaultManager;
- (BOOL)isImageCached:(NSString*)trackId imageType:(ImageType)imageType;
- (void)cacheImageWithTractId:(NSString*)trackId imageType:(ImageType)imageType tempLoc:(NSURL*)tempUrl completion:(myCompletion)completionHandler;
- (NSURL*)imageDirForTrackId:(NSString*)trackId imageType:(ImageType)imageType;

@end

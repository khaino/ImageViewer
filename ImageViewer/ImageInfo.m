//
//  Image.m
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "ImageInfo.h"
#import "ImageInfoManager.h"


@implementation ImageInfo

@synthesize imageId = _imageId;
@synthesize downloadCompleted = _downloadCompleted;
@synthesize locUrl = _locUrl;
@synthesize lastAccess = _lastAccess;

- (instancetype)initWithTrackId:(NSString*)trackId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess
{
    self = [super self];
    if (self) {
        _trackId = trackId;
        _isThumpnail = isThumpnail;
        _downloadCompleted = completed;
        _locUrl = locUrl;
        _lastAccess = lastAcess;
    }
    return self;
}

- (instancetype)initWithImageId:(NSString*)imageId
                        trackId:(NSString*)trackId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess
{
    self = [super self];
    if (self) {
        
        _imageId = imageId;
        _trackId = trackId;
        _isThumpnail = isThumpnail;
        _downloadCompleted = completed;
        _locUrl = locUrl;
        _lastAccess = lastAcess;
    }
    return self;
}




#pragma setters

/*
 * @brief Setter for Image Id
 * @param imageId image id.
 * @return none.
 */
- (void)setImageId:(NSString *)imageId {
    if (imageId != nil && imageId != _imageId) {
        _imageId = imageId;
        _lastAccess = [[NSDate date] description];
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}

/*
 * @brief Setter of download completed field
 * @param downloadCompleted download completed.
 * @return none.
 */
- (void)setDownloadCompleted:(BOOL)downloadCompleted {
    if (downloadCompleted != _downloadCompleted) {
        _downloadCompleted = downloadCompleted;
        _lastAccess = [[NSDate date] description];
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}

/*
 * @brief Setter of locUrl field
 * @param locUrl location url.
 * @return none.
 */
- (void)setLocUrl:(NSURL *)locUrl {
    if (locUrl != nil && locUrl != _locUrl) {
        _locUrl = locUrl;
        _lastAccess = [[NSDate date] description];
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}

/*
 * @brief Setter of lastAccess field
 * @param lastAccess last access time.
 * @return none.
 */
- (void)setLastAccess:(NSString *)lastAccess {
    if (lastAccess != nil && lastAccess != _lastAccess) {
        _lastAccess = lastAccess;
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}


@end

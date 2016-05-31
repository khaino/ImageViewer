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

- (void)setImageId:(NSString *)imageId {
    if (imageId != nil && imageId != _imageId) {
        _imageId = imageId;
    }
}

- (void)setDownloadCompleted:(BOOL)downloadCompleted {
    if (downloadCompleted != _downloadCompleted) {
        _downloadCompleted = downloadCompleted;
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}

- (void)setLocUrl:(NSURL *)locUrl {
    if (locUrl != nil && locUrl != _locUrl) {
        _locUrl = locUrl;
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}

- (void)setLastAccess:(NSString *)lastAccess {
    if (lastAccess != nil && lastAccess != _lastAccess) {
        _lastAccess = lastAccess;
        [[ImageInfoManager defaultManager] updateImageInfo:self];
    }
}

@end

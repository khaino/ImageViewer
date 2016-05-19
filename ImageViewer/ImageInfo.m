//
//  Image.m
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "ImageInfo.h"

@implementation ImageInfo

- (instancetype)initWithTrackId:(NSString*)imageId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess
{
    self = [super self];
    if (self) {
        _imageId = imageId;
        _isThumpnail = isThumpnail;
        _downloadCompleted = completed;
        _locUrl = locUrl;
        _lastAccess = lastAcess;
    }
    return self;
}

- (void)setImageId:(NSString *)imageId {
    if (imageId != nil && _imageId != imageId) {
        _imageId = imageId;
    }
}

@end

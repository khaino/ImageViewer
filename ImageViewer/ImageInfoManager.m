//
//  ImageInfoManager.m
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "ImageInfoManager.h"
#import "ImageDatabase.h"
#import "ImageInfo.h"

@interface ImageInfoManager()

@property(strong, nonatomic) NSMutableDictionary *allImageInfo;

@end

@implementation ImageInfoManager

static ImageInfoManager *imageInfoManager;

+ (instancetype)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageInfoManager = [[self alloc] init];
        [ImageDatabase createDB];
        imageInfoManager.allImageInfo = [ImageDatabase getAllPersonInfo];
    });
    
    return imageInfoManager;
}

- (NSArray*)getAllImageInfo {
    return [self.allImageInfo allValues];
}

- (NSArray*)getImageInfo:(NSString*)imageId {
    return [self.allImageInfo objectForKey:imageId];
}

- (BOOL)insertImageInfo:(ImageInfo*)imageInfo {
    BOOL ret = NO;
    if (imageInfo != nil && imageInfo) {
        if ([ImageDatabase insertOrUpdateImageInfo:imageInfo]) {
            [self.allImageInfo setObject:imageInfo forKey:imageInfo.imageId];
            ret = YES;
        }
    }
    return ret;
}

- (BOOL)updateImageInfo:(ImageInfo*)imageInfo {
    BOOL ret = NO;
    if (imageInfo != nil) {
        if ([ImageDatabase insertOrUpdateImageInfo:imageInfo]) {
            [self.allImageInfo setObject:imageInfo forKey:imageInfo.imageId];
            ret = YES;
        }
    }
    return ret;
}

@end

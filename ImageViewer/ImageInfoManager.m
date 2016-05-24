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
        imageInfoManager.allImageInfo = [ImageDatabase getAllImageInfo];
    });
    
    return imageInfoManager;
}

- (NSArray*)getAllImageInfoWithType:(ImageType)imageType {
    
    NSArray *allImages = [self.allImageInfo allValues];
    
    NSPredicate *predicate;
    
    if (imageType == k60) {
        predicate = [NSPredicate predicateWithFormat:@"isThumpnail = YES"];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"isThumpnail = NO"];
    }
    
    NSArray *imgInfoArr = [allImages filteredArrayUsingPredicate:predicate];
    return imgInfoArr;
}

- (NSInteger)countImageWithType:(ImageType)imageType {
 
    return [self getAllImageInfoWithType:imageType].count;
}

- (NSArray*)getImageInfo:(NSString*)imageId {
    
    return [self.allImageInfo objectForKey:imageId];
}

- (BOOL)insertImageInfo:(ImageInfo*)imageInfo {
    BOOL ret = NO;
    if (imageInfo != nil && imageInfo) {
        if ([ImageDatabase insertOrUpdateImageInfo:imageInfo]) {
            NSString *imageId = [ImageDatabase getLastInsertRowId];
            [self.allImageInfo setObject:imageInfo forKey:imageId];
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

- (BOOL)deleteImageInfo:(NSString*)imageId {
    return [ImageDatabase deleteImageInfo:imageId];
}

@end

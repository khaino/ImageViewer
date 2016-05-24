//
//  ImageInfoManager.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageInfo.h"

/*
 * Disposition options for various delegate messages
 */
typedef NS_ENUM(NSInteger) {
    /** Image size for thumpnail 60*60 */
    k60 = 0,
    /** Image size for normal 600*600 */
    k600 = 1
} ImageType;

@interface ImageInfoManager : NSObject

+ (instancetype)defaultManager;
- (NSArray*)getAllImageInfoWithType:(ImageType)imageType;
- (NSArray*)getImageInfo:(NSString*)imageId;
- (BOOL)insertImageInfo:(ImageInfo*)imageInfo;
- (BOOL)updateImageInfo:(ImageInfo*)imageInfo;
- (BOOL)deleteImageInfo:(NSString*)imageId;

@end

//
//  ImageInfoManager.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageInfo.h"
#import "EnumType.h"

@interface ImageInfoManager : NSObject

+ (instancetype)defaultManager;
- (NSArray*)getAllImageInfoWithType:(ImageType)imageType;
- (NSArray*)getImageInfo:(NSString*)imageId;
- (BOOL)insertImageInfo:(ImageInfo*)imageInfo;
- (BOOL)updateImageInfo:(ImageInfo*)imageInfo;
- (BOOL)deleteImageInfo:(NSString*)imageId;
- (NSString*)getLastInsertRowIdWithImageInfo:(ImageInfo*)imageInfo;

@end

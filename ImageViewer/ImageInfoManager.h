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
/** This class manage database operation */
@interface ImageInfoManager : NSObject

/*
 * @brief Default manager.
 * @return Return Image info manager.
 */
+ (instancetype)defaultManager;

/*
 * @brief Get all images info for give type.
 * @param imageType image type.
 * @return Return Array of image info.
 */
- (NSArray*)getAllImageInfoWithType:(ImageType)imageType;

/*
 * @brief Get image info of a given image id.
 * @param imageId image id.
 * @return Return Image Info.
 */
- (NSArray*)getImageInfo:(NSString*)imageId;

/*
 * @brief Insert image info.
 * @param imageInfo image info.
 * @return Return YES on successful, NO otherwise.
 */
- (BOOL)insertImageInfo:(ImageInfo*)imageInfo;

/*
 * @brief Update image info.
 * @param imageInfo image info.
 * @return Return YES on successful, NO otherwise.
 */
- (BOOL)updateImageInfo:(ImageInfo*)imageInfo;

/*
 * @brief Delete image info.
 * @param imageId image id.
 * @return Return YES on successful, NO otherwise.
 */
- (BOOL)deleteImageInfo:(NSString*)imageId;

/*
 * @brief Get last inserted image id.
 * @param imageInfo image info.
 * @return Return image id.
 */
- (NSString*)getLastInsertRowIdWithImageInfo:(ImageInfo*)imageInfo;

@end

//
//  ImageDatabase.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageInfo.h"
/** This class is to perform database operation */
@interface ImageDatabase : NSObject

/*
 * @brief Create image database.
 * @return Return YES on successful, NO otherwise.
 */
+ (BOOL) createDB;

/*
 * @brief Get all image info.
 * @return Return dictonary of all images.
 */
+ (NSMutableDictionary*)getAllImageInfo;

/*
 * @brief Insert or update image information.
 * @param imageInfo Image information.
 * @return Return YES on successful, NO otherwise.
 */
+ (BOOL)insertOrUpdateImageInfo:(ImageInfo*) imageInfo;

/*
 * @brief Get image id of last inserted.
 * @param imageInfo Image information.
 * @return Return image id.
 */
+ (NSString*)getLastInsertRowIdImageInfo:(ImageInfo*)imageInfo;

/*
 * @brief Delete image information.
 * @param imageId Image id.
 * @return Return YES on successful, NO otherwise.
 */
+ (BOOL)deleteImageInfo:(NSString*)imageId;

@end

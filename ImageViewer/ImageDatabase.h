//
//  ImageDatabase.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageInfo.h"

@interface ImageDatabase : NSObject

+ (BOOL) createDB;
+ (NSMutableDictionary*)getAllImageInfo;
+ (BOOL)insertOrUpdateImageInfo:(ImageInfo*) imageInfo;
+ (NSString*)getLastInsertRowIdImageInfo:(ImageInfo*)imageInfo;
+ (BOOL)deleteImageInfo:(NSString*)imageId;

@end

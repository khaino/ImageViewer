//
//  ImageInfoManager.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageInfo.h"

@interface ImageInfoManager : NSObject

+ (instancetype)defaultManager;
- (NSArray*)getAllImageInfo;
- (NSArray*)getImageInfo:(NSString*)imageId;
- (BOOL)insertImageInfo:(ImageInfo*)imageInfo;
- (BOOL)updateImageInfo:(ImageInfo*)imageInfo;

@end

//
//  IVImageDownload.h
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVCacheManager.h"

/**
 *This class is to manage image download
 */
@interface IVImageDownload : NSObject

/*
 * @brief Download image at give url
 * @param url url for image
 * @param trackId Podcast image track id.
 * @param imageType image type.
 * @param completionHandler completion handler.
 * @return none.
 */
- (void)downloadImage:(NSURL*)url trackId:(NSString*)trackId imageType:(ImageType)imageType completionHandler:(myCompletion)completion;

@end

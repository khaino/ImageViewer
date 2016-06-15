//
//  Image.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
/** This class represents information needed for an image */
@interface ImageInfo : NSObject

/** imageId of image. */
@property(nonatomic)NSString *imageId;
/** track id of image. */
@property(strong, nonatomic)NSString *trackId;
/** is image is thumnail */
@property(nonatomic)BOOL isThumpnail;
/** image download has been completed. */
@property(nonatomic)BOOL downloadCompleted;
/** location url for downloaded image. */
@property(strong, nonatomic)NSURL *locUrl;
/** last access time for an image. */
@property(strong, nonatomic)NSString *lastAccess;

/*
 * @brief Init image without image id
 * @param trackId track id of image.
 * @param isThumpnail is image thumpnail.
 * @param locUrl default location of downloaded image.
 * @param lastAcess last accesss time of image.
 * @return Return ImageInfo.
 */
- (instancetype)initWithTrackId:(NSString*)trackId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess;


/*
 * @brief Init image with image id
 * @param imageId image id.
 * @param trackId track id of image.
 * @param isThumpnail is image thumpnail.
 * @param locUrl default location of downloaded image.
 * @param lastAcess last accesss time of image.
 * @return Return ImageInfo.
 */
- (instancetype)initWithImageId:(NSString*)imageId
                        trackId:(NSString*)trackId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess;

@end

//
//  IVImageDownload.m
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVImageDownload.h"
#import "ImageInfoManager.h"
#import "ImageInfo.h"

@interface IVImageDownload()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

/** session for download. */
@property (strong, nonatomic) NSURLSession *session;
/** completion handler for callback. */
@property (nonatomic) myCompletion completionHandler;
/** track id to download. */
@property (strong, nonatomic) NSString *trackId;
/** image type to download */
@property (nonatomic) ImageType imageType;
/** image information for download */
@property (strong, nonatomic)ImageInfo *imageInfo;

@end

@implementation IVImageDownload

#pragma mark- setter

/*
 * @brief Setter for session property.
 * @return NSURLSession.
 */
- (NSURLSession*)session {
    
    if(!_session) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma mark- public method implementation

- (void)downloadImage:(NSURL*)url
              trackId:(NSString*)trackId
            imageType:(ImageType)imageType
    completionHandler:(myCompletion)completion {
    
    self.trackId = trackId;
    self.completionHandler = completion;
    self.imageType = imageType;
    NSDate *date = [NSDate date];
    IVCacheManager *cacheManager = [IVCacheManager defaultManager];
    if ([cacheManager isImageCached:trackId imageType:imageType]) {
        NSURL *imgUrl = [cacheManager imageDirForTrackId:trackId imageType:imageType];
        //-----------------------------------------------------------------
        // Insert new Image Info if not exists in db else update lastAccess
        //-----------------------------------------------------------------
        ImageInfo *imageInfo = [[ImageInfoManager defaultManager] getImageInfoWithTrackId:trackId andType:imageType];
        if (imageInfo == nil) {
            self.imageInfo = [[ImageInfo alloc]initWithTrackId:self.trackId
                                                   isThumpnail:(imageType == k60)?YES:NO
                                             downloadCompleted:NO
                                                        locUrl:nil
                                                     lassAcess:[date description]];
            [[ImageInfoManager defaultManager] insertImageInfo:imageInfo];
            imageInfo.imageId = [[ImageInfoManager defaultManager] getLastInsertRowIdWithImageInfo:self.imageInfo];
        } else {
            imageInfo.lastAccess = [date description];
            [[ImageInfoManager defaultManager] updateImageInfo:imageInfo];
            DDLogDebug(@"Update last access for image id %@", imageInfo.imageId);
        }

        self.completionHandler(imgUrl);
    } else {

        [[self.session downloadTaskWithURL:url] resume];
        BOOL isThumpnail = (imageType == k60)? YES : NO;
        self.imageInfo = [[ImageInfo alloc]initWithTrackId:self.trackId
                                                              isThumpnail:isThumpnail
                                                        downloadCompleted:NO
                                                                   locUrl:nil
                                                                lassAcess:[date description]];
        [[ImageInfoManager defaultManager] insertImageInfo:self.imageInfo];
        self.imageInfo.imageId = [[ImageInfoManager defaultManager] getLastInsertRowIdWithImageInfo:self.imageInfo];
        DDLogDebug(@"Download start image id : %@, image type : %ld", self.imageInfo.imageId, (long)self.imageType);

    }
}

#pragma mark- private methods

/*
 * @brief Get image dir for given track id.
 * @param trackId Podcast image track id.
 * @param completionHandler completion handler.
 * @return NSURL url for image dir.
 */
- (NSURL *)imageDirectoryForTrackId:(NSString *)trackId{
    
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *subDir = [NSString stringWithFormat:@"image/%@", trackId];
    NSURL *url = [documents URLByAppendingPathComponent:subDir];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            DDLogError(@"Unable to create image directory. %@, %@", error, error.userInfo);
        }
    }
    return url;
}


#pragma mark- URLSession delegate methods

/*
 * @brief Callback when download completed.
 * @param session nsurl sesson.
 * @param downloadTask download task.
 * @param location location for temp file.
 * @return none.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    [[IVCacheManager defaultManager] cacheImageWithTractId:self.trackId imageType:self.imageType tempLoc:location completion:^(NSURL *url) {
        self.imageInfo.downloadCompleted = YES;
        self.imageInfo.locUrl = location;
        self.completionHandler(url);
        DDLogDebug(@"Download complete image id : %@, image type : %ld", self.imageInfo.imageId, (long)self.imageType);
    }];
    [self.session invalidateAndCancel];
}

/*
 * @brief Callback when download completed.
 * @param task nsurl session task.
 * @param error error.
 * @return none.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        [[ImageInfoManager defaultManager] deleteImageInfo:self.imageInfo.imageId];
        DDLogError(@"Download error image id : %@, image type : %ld", self.imageInfo.imageId, (long)self.imageType);
    }
    [self.session invalidateAndCancel];
}


@end


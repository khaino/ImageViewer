//
//  IVImageDownload.m
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVImageDownload.h"
#import "IVCacheManager.h"
@interface IVImageDownload()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (nonatomic) myCompletion completionHandler;
@property (strong, nonatomic) NSString *trackId;

@end

@implementation IVImageDownload

#pragma setter

- (NSURLSession*)session {
    
    if(!_session) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma private methods

- (void)downloadImage:(NSURL*)url trackId:(NSString*)trackId completionHandler:(myCompletion)completion{
    
    self.trackId = trackId;
    self.completionHandler = completion;
    
    IVCacheManager *cacheManager = [IVCacheManager defaultManager];
    if ([cacheManager isImageCached:trackId imageType:k60]) {
        NSURL *imgUrl = [cacheManager imageDirForTrackId:trackId imageType:k60];
        self.completionHandler(imgUrl);
    } else {
        NSLog(@"Download image no : %@",trackId);
        [[self.session downloadTaskWithURL:url] resume];
    }
}

- (NSURL *)imageDirectoryForTrackId:(NSString *)trackId{
    
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *subDir = [NSString stringWithFormat:@"image/%@", trackId];
    NSURL *url = [documents URLByAppendingPathComponent:subDir];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Unable to create image directory. %@, %@", error, error.userInfo);
        }
    }
    return url;
}


#pragma delegate methods


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    [[IVCacheManager defaultManager] cacheImageWithTractId:self.trackId imageType:k60 tempLoc:location completion:^(NSURL *url) {
        self.completionHandler(url);
    }];
    [self.session invalidateAndCancel];
}


@end


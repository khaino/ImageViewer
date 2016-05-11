//
//  IVImageDownload.m
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVImageDownload.h"
@interface IVImageDownload()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (nonatomic) myCompletion completionHandler;
@property (strong, nonatomic) NSString *trackId;

@end

@implementation IVImageDownload




#pragma private methods

- (void)downloadImage:(NSURL*)url trackId:(NSString*)trackId completionHandler:(myCompletion)completion{
    
    self.trackId = trackId;
    self.completionHandler = completion;
    [[self.session downloadTaskWithURL:url] resume];
}

- (NSURLSession*)session {
    
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // Initialize Session
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    });
    return session;
}

- (void)moveFileWithURL:(NSURL *)tempUrl downloadTask:(NSURLSessionDownloadTask *)downloadTask {

    NSURL *url = [[downloadTask originalRequest] URL];
    NSString *fileName = [url lastPathComponent];
    

    NSURL *localUrl = [self imageDirectoryForTrackId:self.trackId];
    NSURL *fileUrl = [localUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:[tempUrl path]]) {
        NSError *error = nil;
        [fm moveItemAtURL:tempUrl toURL:fileUrl error:&error];
        
        if (error) {
            NSLog(@"Unable to move temporary file to destination. %@, %@", error, error.userInfo);
        } else {
            if (self.completionHandler) {
                self.completionHandler(fileUrl);
            }
        }
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
    // Write File to Disk
    [self moveFileWithURL:location downloadTask:downloadTask];
    
}


@end


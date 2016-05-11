//
//  IVImageDownload.m
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVImageDownload.h"
@interface IVImageDownload()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

typedef NSURL*(^myCompletion)(void);

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableDictionary *downLoadDic;
@property (nonatomic) myCompletion completionHandler;

@end

@implementation IVImageDownload




#pragma private methods

- (void)downloadImage:(NSURL*)url trackId:(NSString*)trackId completionHandler:(myCompletion)completion{
    
    self.completionHandler = completion;
    [[self.session downloadTaskWithURL:url] resume];
    [self.downLoadDic setObject:trackId forKey:[url description]];
    
}

- (NSMutableDictionary*)downLoadDic {
    if (_downLoadDic) {
        _downLoadDic = [NSMutableDictionary dictionary];
    }
    return _downLoadDic;
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
    

    NSURL *localDir = [self imageDirectoryForTrackId:[self.downLoadDic objectForKey:[url description]]];
    NSURL *localUrl = [localDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:[tempUrl path]]) {
        NSError *error = nil;
        [fm moveItemAtURL:tempUrl toURL:localUrl error:&error];
        
        if (error) {
            NSLog(@"Unable to move temporary file to destination. %@, %@", error, error.userInfo);
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

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
////    // Calculate Progress
////    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
////    
////    // Update Progress Buffer
////    NSURL *URL = [[downloadTask originalRequest] URL];
////    [self.progressBuffer setObject:@(progress) forKey:[URL absoluteString]];
////    
////    // Update Table View Cell
////    MTEpisodeCell *cell = [self cellForForDownloadTask:downloadTask];
////    
////    dispatch_async(dispatch_get_main_queue(), ^{
////        [cell setProgress:progress];
////    });
//}



//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}


@end


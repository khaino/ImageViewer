//
//  DownloadJSON.h
//  ImageViewer
//
//  Created by NCAung on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Podcast.h"
#import "PodcastDBManager.h"

@interface DownloadJSON : NSObject
- (void)search:(NSString *)keyword completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))myCompletion;
@end

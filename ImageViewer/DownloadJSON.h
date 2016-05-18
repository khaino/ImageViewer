//
//  DownloadJSON.h
//  ImageViewer
//
//  Created by user on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Podcast.h"
#import "PodcastDBManager.h"

@interface DownloadJSON : NSObject
@property (strong, nonatomic) NSArray *results;
- (void)performSearch:(NSString *)keyword;
@end

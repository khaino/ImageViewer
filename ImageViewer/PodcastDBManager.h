//
//  PodcastDBManager.h
//  ImageViewer
//
//  Created by user on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Podcast.h"

@interface PodcastDBManager : NSObject
+ (instancetype)defaultManager;
- (NSArray *)getAllPodcast;
- (BOOL)insertPodcast:(Podcast *)podcast;
@end

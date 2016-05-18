//
//  PodcastDBManager.m
//  ImageViewer
//
//  Created by user on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "PodcastDBManager.h"
#import "PodcastDAO.h"

@interface PodcastDBManager()
@property(strong, nonatomic) NSMutableDictionary *podcastDict;
@end

@implementation PodcastDBManager

static PodcastDBManager *podcastDBManager;

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        podcastDBManager = [[self alloc] init];
        podcastDBManager.podcastDict = [PodcastDAO loadDB];
    });
    return podcastDBManager;
}

- (NSArray*)getAllPodcast {
    return [self.podcastDict allValues];
}

- (BOOL)insertPodcast:(Podcast *)podcast {
    if (podcast != nil) {
        if ([PodcastDAO insertOrUpdatePodcast:podcast]) {
            [self.podcastDict setObject:podcast forKey:podcast.trackID];
            return YES;
        }
    }
    return NO;
}


@end

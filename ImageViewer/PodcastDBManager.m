//
//  PodcastDBManager.m
//  ImageViewer
//
//  Created by NCAung on 5/16/16.
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
    
    // Set sort pattern on database results with insert date
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"insertDate" ascending:NO];
    NSArray *sortDescriptors = @[descriptor];
    self.podcastDict = [PodcastDAO loadDB];
    return [[self.podcastDict allValues] sortedArrayUsingDescriptors:sortDescriptors];
}

- (BOOL)insertPodcast:(NSArray *)podcasts {
    if (podcasts != nil) {
        for (Podcast *podcast in podcasts) {
            [PodcastDAO insertOrUpdatePodcast:podcast];
//            [self.podcastDict setObject:podcast forKey:podcast.trackID];
        }
        [PodcastDAO deleteRedundantRows];
        return YES;
    }
    return NO;
}

@end

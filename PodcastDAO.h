//
//  PodcastDAO.h
//  ImageViewer
//
//  Created by user on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Podcast.h"

@interface PodcastDAO : NSObject

+ (NSMutableDictionary *)loadDB;
+ (BOOL)insertOrUpdatePodcast: (Podcast *) podcast;

@end

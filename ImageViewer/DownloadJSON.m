//
//  DownloadJSON.m
//  ImageViewer
//
//  Created by user on 5/12/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "DownloadJSON.h"

@interface DownloadJSON ()
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSArray *podcasts;
@end

@implementation DownloadJSON

//
// Configuration and initializing session
//
- (NSURLSession *)session {
    if (!_session) {
        
        // Initialize Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Configure Session Configuration
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
        // Initialize Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
 
    return _session;
}

//
// Searching the data with keyword
//
- (void)performSearch:(NSString *)keyword {

    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    self.dataTask = [self.session dataTaskWithURL:[self urlForQuery:keyword] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (error.code != -999) {
                NSLog(@"%@", error);
            }
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = [result objectForKey:@"results"];
            if (results) {
                [self processResults:results];
            }
        }
    }];
    
    if (self.dataTask) {
        [self.dataTask resume];
    }
}

//
// Desination for search
//
- (NSURL *)urlForQuery:(NSString *)keyword {
    keyword = [keyword stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?media=podcast&entity=podcast&term=%@", keyword]];
}

//
// Inserting search results to podcasts database
//
- (void)processResults:(NSArray *)results {
    for (NSDictionary *dict in results) {
        Podcast *podcast = [[Podcast alloc]init];
        [podcast setTrackID:[dict objectForKey:@"trackId"]];
        [podcast setCollectionName:[dict objectForKey:@"collectionName"]];
        [podcast setArtistName:[dict objectForKey:@"artistName"]];
        [podcast setSmallImage:[dict objectForKey:@"artworkUrl60"]];
        [podcast setLargeImage:[dict objectForKey:@"artworkUrl600"]];
        [[PodcastDBManager defaultManager] insertPodcast:podcast];
    }
}


////
//// Inserting search results to podcasts array
////
//- (BOOL)processResults:(NSArray *)results {
//    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
//    for (NSDictionary *dict in results) {
//        Podcast *podcast = [[Podcast alloc]init];
//        [podcast setTrackID:[dict objectForKey:@"trackId"]];
//        [podcast setCollectionName:[dict objectForKey:@"collectionName"]];
//        [podcast setArtistName:[dict objectForKey:@"artistName"]];
//        [podcast setSmallImage:[dict objectForKey:@"artworkUrl60"]];
//        [podcast setLargeImage:[dict objectForKey:@"artworkUrl600"]];
//        [tempArray addObject:podcast];
//    }
//    self.podcasts = tempArray;
//    return YES;
//}
@end

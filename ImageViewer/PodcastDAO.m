//
//  PodcastDAO.m
//  ImageViewer
//
//  Created by NCAung on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "PodcastDAO.h"

NSString *dbPodcast = @"podcast.db";

@implementation PodcastDAO

+ (BOOL) createDB {
    BOOL ret = NO;
    sqlite3 *db;
    NSString *dbPath = [PodcastDAO getDBPath:dbPodcast];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
            NSString *sql= @"CREATE TABLE IF NOT EXISTS podcast (id INTEGER, track_id TEXT PRIMARY KEY UNIQUE, collection_name TEXT, artist_name TEXT, image_small TEXT, image_large TEXT)";
            char *error;
            if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
                ret = YES;
                NSLog(@"Podcast table has been sucessfully created");
            } else {
                NSLog(@"Error: %s", error);
            }
        }
        sqlite3_close(db);
    } else {
        NSLog(@"Database file already exist");
    }
    return ret;
}

+ (NSString *) getDBPath:(NSString *)dbname {
    // Create a string containing the full path to the dbname.db inside the documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:dbname];
    return databasePath;
}

+ (NSMutableDictionary*)loadDB {
    [PodcastDAO createDB];
    return [PodcastDAO getAllPodcast];
}

+ (NSMutableDictionary*)getAllPodcast {
    sqlite3 *db;
    NSMutableDictionary *allPodcast = [NSMutableDictionary dictionary];
    if (sqlite3_open([[PodcastDAO getDBPath:dbPodcast] UTF8String], &db) == SQLITE_OK) {
        NSString *sql = @"SELECT track_id, collection_name, artist_name, image_small, image_large FROM podcast ORDER BY id asc";
        NSLog(@"Select query: %@", sql);
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                NSString *trackID = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];
                NSString *collectionName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
                NSString *artistName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
                NSString *smallImage = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
                NSString *largeImage = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
                Podcast *podcast = [[Podcast alloc] init];
                [podcast setTrackID:trackID];
                [podcast setCollectionName:collectionName];
                [podcast setArtistName:artistName];
                [podcast setSmallImage:smallImage];
                [podcast setLargeImage:largeImage];
                [allPodcast setObject:podcast forKey:podcast.trackID];
                NSLog(@"Podcast selected");
            }
        }
        sqlite3_finalize(stmt);
    }
    sqlite3_close(db);
    return allPodcast;
}

+ (BOOL)insertOrUpdatePodcast:(Podcast *)podcast {
    BOOL ret = NO;
    sqlite3 *db;
    NSString *query =@"INSERT OR REPLACE INTO podcast (id, track_id, collection_name, artist_name, image_small, image_large) VALUES ((SELECT IFNULL(MAX(id), 0) + 1 FROM podcast), \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")";
    if (sqlite3_open([[PodcastDAO getDBPath:dbPodcast] UTF8String], &db) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:query, podcast.trackID, podcast.collectionName, podcast.artistName, podcast.smallImage, podcast.largeImage];
        char *error;
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            ret = YES;
            NSLog(@"Podcast info inserted.");
            NSLog(@"%@", podcast.trackID);
            NSLog(@"%@", podcast.collectionName);
            NSLog(@"%@", podcast.artistName);
            NSLog(@"%@", podcast.smallImage);
            NSLog(@"%@", podcast.largeImage);
        } else {
            NSLog(@"Error: %s", error);
            NSLog(@"Query: %@", query);
            NSLog(@"%@", podcast.trackID);
            NSLog(@"%@", podcast.collectionName);
            NSLog(@"%@", podcast.artistName);
        }
    } else {
        NSLog(@"Database open error : %s", sqlite3_errmsg(db));
    }
    sqlite3_close(db);
    return ret;
}

@end

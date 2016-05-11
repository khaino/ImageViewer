//
//  PodcastDAO.m
//  ImageViewer
//
//  Created by user on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "PodcastDAO.h"

NSString *dbname = @"podcast.db";

@implementation PodcastDAO

+ (BOOL) createDB {
    BOOL ret = NO;
    sqlite3 *db;
    NSString *dbPath = [PodcastDAO getDBPath:dbname];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
            NSString *sql= @"CREATE TABLE IF NOT EXISTS podcast (id INTEGER PRIMARY KEY AUTOINCREMENT, track_id TEXT UNIQUE, track_name TEXT, artist_name TEXT, PRIMARY KEY(track_id ASC))";
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
    if (sqlite3_open([[PodcastDAO getDBPath:dbname] UTF8String], &db) == SQLITE_OK) {
        NSString *sql = @"SELECT track_id, track_name, artist_name FROM podcast ORDER BY id asc";
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                NSString *trackID = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];
                NSString *trackName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
                NSString *artistName = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
                Podcast *podcast = [[Podcast alloc] init];
                [podcast setTrackID:trackID];
                [podcast setTrackName:trackName];
                [podcast setArtistName:artistName];
                [allPodcast setObject:podcast forKey:podcast.trackID];
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
    if (sqlite3_open([[PodcastDAO getDBPath:dbname] UTF8String], &db) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO podcast (track_id, track_name, artist_name) VALUES ('%@', '%@', '%@')", podcast.trackID, podcast.trackName, podcast.artistName];
        char *error;
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            ret = YES;
            NSLog(@"Podcast info inserted.");
        } else {
            NSLog(@"Error: %s", error);
        }
    } else {
        NSLog(@"Database open error : %s", sqlite3_errmsg(db));
    }
    sqlite3_close(db);
    return ret;
}

@end

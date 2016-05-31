//
//  ImageDatabase.m
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "ImageDatabase.h"
#import "sqlite3.h"


NSString *dbimagename = @"image.db";

@implementation ImageDatabase


+ (BOOL) createDB {
    
    BOOL ret = NO;
    sqlite3 *db;
    NSString *dbPath = [self getDBPath:dbimagename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        
        if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
            
            NSString *sql= @"CREATE TABLE IF NOT EXISTS image (id INTEGER PRIMARY KEY AUTOINCREMENT, track_id TEXT UNIQUE, is_thumpnail BOOL, download_completed BOOL, loc_url TEXT, last_access DATE)";
            
            char *error;
            if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
                ret = YES;
                NSLog(@"Table has been sucessfully created");
            } else {
                NSLog(@"Error: %s", error);
            }
        }
        sqlite3_close(db);
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

+ (NSMutableDictionary*)getAllImageInfo {
    
    sqlite3 *db;
    NSMutableDictionary *allImageInfo = [NSMutableDictionary dictionary];
    
    if (sqlite3_open([[self getDBPath:dbimagename] UTF8String], &db) == SQLITE_OK) {
        
        NSString *sql = @"SELECT track_id, is_thumpnail, download_completed, loc_url, last_access image ORDER BY id asc";
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                NSString *imageId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];
                NSString *trackId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
                BOOL isThumpnail  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
                BOOL downloadCompleted = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
                NSString *locUrl = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];
                NSString *lastAccess = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 5)];

                
                ImageInfo *imageInfo = [[ImageInfo alloc]initWithImageId:imageId
                                                                 trackId:trackId
                                                            isThumpnail:isThumpnail
                                                      downloadCompleted:downloadCompleted
                                                                  locUrl:[NSURL URLWithString:locUrl]
                                                              lassAcess:lastAccess];
                
                [allImageInfo setObject:imageInfo forKey:imageId];
            }
        }
        sqlite3_finalize(stmt);
    }
    sqlite3_close(db);
    
    return allImageInfo;
}


+ (NSString*)getLastInsertRowIdImageInfo:(ImageInfo*)imageInfo {
    
    sqlite3 *db;
    NSString *imageId;
    if (sqlite3_open([[self getDBPath:dbimagename] UTF8String], &db) == SQLITE_OK) {
        //select id from image where track_id = '75908431' and is_thumpnail = 1;
//        NSString *sql = @"SELECT id FROM image WHERE track_id = '%@' AND is_thumpnail = '%d'";
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM image WHERE track_id = '%@' AND is_thumpnail = '%d'", imageInfo.trackId, imageInfo.isThumpnail];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                imageId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];//
                
            }
        }
        sqlite3_finalize(stmt);
    }
    sqlite3_close(db);
    
    return imageId;
}

+ (BOOL)insertOrUpdateImageInfo: (ImageInfo*) imageInfo {
    
    BOOL ret = NO;
    sqlite3 *db;
    if (sqlite3_open([[self getDBPath:dbimagename] UTF8String], &db) == SQLITE_OK) {
        
        // Create sql statement for insert
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO image (track_id, is_thumpnail, download_completed, loc_url, last_access) VALUES ('%@', '%d', '%d', '%@', '%@')", imageInfo.trackId, imageInfo.isThumpnail, imageInfo.downloadCompleted, imageInfo.locUrl.path, imageInfo.lastAccess];
        
        char *error;
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            ret = YES;
            NSLog(@"Image info inserted or modified");
        } else {
            NSLog(@"Error: %s", error);
        }
    } else {
        NSLog(@"Database open error : %s", sqlite3_errmsg(db));
    }
    
    sqlite3_close(db);
    return ret;
}

+ (BOOL)deleteImageInfo:(NSString*)imageId {

    BOOL ret = NO;
    sqlite3 *db;
    if (sqlite3_open([[self getDBPath:dbimagename] UTF8String], &db) == SQLITE_OK) {
        
        // Create sql statement for delete
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM image WHERE imageId = '%@')", imageId];
        
        char *error;
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            ret = YES;
            NSLog(@"Image deleted %@", imageId);
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

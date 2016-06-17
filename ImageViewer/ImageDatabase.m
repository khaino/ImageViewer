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
static sqlite3 *db;

@implementation ImageDatabase


+ (BOOL) createDB {
    
    BOOL ret = NO;

    NSString *dbPath = [self getDBPath:dbimagename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        
        if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
            
            NSString *sql= @"CREATE TABLE IF NOT EXISTS image (id INTEGER PRIMARY KEY AUTOINCREMENT, track_id TEXT, is_thumpnail BOOL, download_completed BOOL, loc_url TEXT, last_access DATE, UNIQUE (track_id, is_thumpnail) ON CONFLICT REPLACE)";
            DDLogDebug(@"SQL Statement : %@", sql);
            char *error;
            if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
                ret = YES;
                DDLogDebug(@"Table has been sucessfully created");
            } else {
                DDLogError(@"Error: %s", error);
            }
        }
//        sqlite3_close(db);
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
    
//    sqlite3 *db;
    NSMutableDictionary *allImageInfo = [NSMutableDictionary dictionary];
    
    if ([self openDatabase]) {
        
        NSString *sql = @"SELECT id, track_id, is_thumpnail, download_completed, loc_url, last_access image ORDER BY id asc";
        DDLogDebug(@"SQL Statement : %@", sql);
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                NSString *imageId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];
                NSString *trackId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
                BOOL isThumpnail  = (BOOL)sqlite3_column_int(stmt, 2);
                BOOL downloadCompleted = (BOOL)sqlite3_column_int(stmt, 3);
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
//    sqlite3_close(db);
    
    return allImageInfo;
}


+ (NSString*)getLastInsertRowIdImageInfo:(ImageInfo*)imageInfo {
    
//    sqlite3 *db;
    NSString *imageId;
    if ([self openDatabase]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM image WHERE track_id = '%@' AND is_thumpnail = '%d'", imageInfo.trackId, imageInfo.isThumpnail];
        DDLogDebug(@"SQL Statement : %@", sql);
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                imageId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];//
                
            }
        }
        sqlite3_finalize(stmt);
    }
//    sqlite3_close(db);
    
    return imageId;
}

+ (BOOL)insertOrUpdateImageInfo: (ImageInfo*) imageInfo {
    
    BOOL ret = NO;
//    sqlite3 *db;
    if ([self openDatabase]) {
        
        // Create sql statement for insert
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO image (track_id, is_thumpnail, download_completed, loc_url, last_access) VALUES ('%@', '%d', '%d', '%@', '%@')", imageInfo.trackId, imageInfo.isThumpnail, imageInfo.downloadCompleted, imageInfo.locUrl.path, imageInfo.lastAccess];
        DDLogDebug(@"SQL Statement : %@", sql);
        char *error;
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            ret = YES;
            //DDLogDebug(@"Image inserted or modified : %@", imageInfo.imageId);
        } else {
            DDLogError(@"Image inserted or modified error : %@", imageInfo.imageId);
        }
    } else {
        DDLogError(@"Database open error : %s", sqlite3_errmsg(db));
    }
    
//    sqlite3_close(db);
    return ret;
}

+ (BOOL)deleteImageInfo:(NSString*)imageId {

    BOOL ret = NO;
//    sqlite3 *db;
    if ([self openDatabase]) {
        
        // Create sql statement for delete
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM image WHERE id = '%@'", imageId];
        DDLogDebug(@"SQL Statement : %@", sql);
        char *error;
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) == SQLITE_OK) {
            ret = YES;
            DDLogDebug(@"Image deleted %@", imageId);
        } else {
            DDLogError(@"Error: %s", error);
        }
    } else {
        DDLogError(@"Database open error : %s", sqlite3_errmsg(db));
    }
    
//    sqlite3_close(db);
    return ret;
}

+ (BOOL)openDatabase {
    BOOL ret = NO;
    if (db) {
        ret = YES;
    } else {
        if (sqlite3_open([[self getDBPath:dbimagename] UTF8String], &db) == SQLITE_OK) ret = YES;
    }
    return ret;
}
@end

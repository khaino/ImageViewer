//
//  ImageDatabase.m
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "ImageDatabase.h"
#import "sqlite3.h"


NSString *dbname = @"image.db";

@implementation ImageDatabase


+ (BOOL) createDB {
    
    BOOL ret = NO;
    sqlite3 *db;
    NSString *dbPath = [self getDBPath:dbname];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        
        if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
            
            NSString *sql= @"CREATE TABLE IF NOT EXISTS image (id INTEGER PRIMARY KEY AUTOINCREMENT, image_id TEXT UNIQUE, is_thumpnail BOOL, download_completed BOOL, loc_url TEXT, last_access DATE)";
            
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

+ (NSMutableDictionary*)getAllPersonInfo {
    
    sqlite3 *db;
    NSMutableDictionary *allImageInfo = [NSMutableDictionary dictionary];
    
    if (sqlite3_open([[self getDBPath:dbname] UTF8String], &db) == SQLITE_OK) {
        
        NSString *sql = @"SELECT image_id, is_thumpnail, download_completed, loc_url, last_access image ORDER BY id asc";
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                NSString *imageId = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 0)];
                BOOL isThumpnail  = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
                BOOL downloadCompleted = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
                NSString *locUrl = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 3)];
                NSString *lastAccess = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 4)];

                
                ImageInfo *imageInfo = [[ImageInfo alloc]initWithTrackId:imageId
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

+ (BOOL)insertOrUpdateImageInfo: (ImageInfo*) imageInfo {
    
    BOOL ret = NO;
    sqlite3 *db;
    if (sqlite3_open([[self getDBPath:dbname] UTF8String], &db) == SQLITE_OK) {
        
        // Create sql statement for insert
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO image (image_id, is_thumpnail, download_completed, loc_url, last_access) VALUES ('%@', '%d', '%d', '%@', '%@')", imageInfo.imageId, imageInfo.isThumpnail, imageInfo.downloadCompleted, imageInfo.locUrl.path, imageInfo.lastAccess];
        
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
@end

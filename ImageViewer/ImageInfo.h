//
//  Image.h
//  ImageViewer
//
//  Created by Khaino on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageInfo : NSObject

@property(nonatomic)NSString *imageId;
@property(strong, nonatomic)NSString *trackId;
@property(nonatomic)BOOL isThumpnail;
@property(nonatomic)BOOL downloadCompleted;
@property(strong, nonatomic)NSURL *locUrl;
@property(strong, nonatomic)NSString *lastAccess;


- (instancetype)initWithTrackId:(NSString*)trackId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess;

- (instancetype)initWithImageId:(NSString*)imageId
                        trackId:(NSString*)trackId
                    isThumpnail:(BOOL)isThumpnail
              downloadCompleted:(BOOL)completed
                         locUrl:(NSURL*)locUrl
                      lassAcess:(NSString*) lastAcess;

@end

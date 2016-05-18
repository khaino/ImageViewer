//
//  Podcast.h
//  ImageViewer
//
//  Created by user on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Podcast : NSObject
@property(strong,nonatomic)NSString *trackID;
@property(strong,nonatomic)NSString *collectionName;
@property(strong,nonatomic)NSString *artistName;
@property(strong,nonatomic)NSString *smallImage;
@property(strong,nonatomic)NSString *largeImage;
@end

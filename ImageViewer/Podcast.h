//
//  Podcast.h
//  ImageViewer
//
//  Created by NCAung on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Podcast : NSObject
@property(strong,nonatomic)NSString *trackID;
@property(strong,nonatomic)NSString *collectionName;
@property(strong,nonatomic)NSString *artistName;
@property(strong,nonatomic)NSString *smallImage;
@property(strong,nonatomic)NSString *largeImage;
@property(strong,nonatomic)NSString *insertDate;
@end

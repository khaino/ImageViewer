//
//  IVImageDownload.h
//  ImageViewer
//
//  Created by Khaino on 5/11/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IVImageDownload : NSObject
typedef void(^myCompletion)(NSURL*);
- (void)downloadImage:(NSURL*)url trackId:(NSString*)trackId completionHandler:(myCompletion)completion;
@end

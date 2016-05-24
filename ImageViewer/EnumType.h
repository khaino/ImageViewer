//
//  EnumType.h
//  ImageViewer
//
//  Created by Khaino on 5/24/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnumType : NSObject
/*
 * Disposition options for various delegate messages
 */
typedef NS_ENUM(NSInteger) {
    /** Image size for thumpnail 60*60 */
    k60 = 0,
    /** Image size for normal 600*600 */
    k600 = 1
}ImageType;

@end

//
//  IVPageContentViewController.h
//  ImageViewer
//
//  Created by user on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Podcast.h"

@interface IVPageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIImage *image;
@property NSUInteger pageIndex;
@property NSString *imageFile;
@property (strong, nonatomic) Podcast *podcast;
@end

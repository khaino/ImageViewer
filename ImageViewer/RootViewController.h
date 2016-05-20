//
//  RootViewController.h
//  ImageViewer
//
//  Created by user on 5/16/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVPageContentViewController.h"

@interface RootViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;
@property (nonatomic, assign) int currentImage;
@end

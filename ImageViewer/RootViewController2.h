//
//  RootViewController2.h
//  ImageViewer
//
//  Created by user on 5/23/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController2 : UIViewController <UIPageViewControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) int currentImage;
@property (strong, nonatomic) NSArray *podcasts;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end

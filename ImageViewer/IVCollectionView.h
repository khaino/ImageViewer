//
//  IVCollectionView.h
//  ImageViewer
//
//  Created by user on 5/23/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVCollectionView : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *imageList;
@property (nonatomic, assign) int currentImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSArray *podcasts;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;
@end
